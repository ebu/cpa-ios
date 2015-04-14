//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "CPAProvider.h"

#import "CPAErrors+Private.h"
#import "CPAStatelessRequest.h"
#import "CPAUICKeyChainStore.h"
#import "CPAToken+Private.h"
#import "CPAWebViewController.h"

#import <UIKit/UIKit.h>

// Typedefs
typedef void (^CPAVoidCompletionBlock)(NSError *error);

// Globals
static CPAProvider *s_defaultProvider = nil;

// Static functions
static NSURL *CPAFullVerificationURL(NSURL *verificationURL, NSString *userCode);
static NSError *CPAErrorFromCallbackURL(NSURL *callbackURL);

@interface CPAProvider ()

@property (nonatomic) NSURL *authorizationProviderURL;
@property (nonatomic) CPAUICKeyChainStore *keyChainStore;

@end

@implementation CPAProvider

#pragma mark Class methods

+ (CPAProvider *)setDefaultProvider:(CPAProvider *)provider
{
    CPAProvider *previousProvider = s_defaultProvider;
    s_defaultProvider = provider;
    return previousProvider;
}

+ (CPAProvider *)defaultProvider
{
    return s_defaultProvider;
}

#pragma mark Object lifecycle

- (instancetype)initWithAuthorizationProviderURL:(NSURL *)authorizationProviderURL
                             keyChainAccessGroup:(NSString *)keyChainAccessGroup
{
    NSParameterAssert(authorizationProviderURL);
    
    if (self = [super init]) {
        self.authorizationProviderURL = authorizationProviderURL;
        
        NSString *serviceIdentifier = [NSBundle mainBundle].bundleIdentifier;
        self.keyChainStore = [CPAUICKeyChainStore keyChainStoreWithService:serviceIdentifier accessGroup:keyChainAccessGroup];
    }
    return self;
}

- (instancetype)initWithAuthorizationProviderURL:(NSURL *)authorizationProviderURL
{
    return [self initWithAuthorizationProviderURL:authorizationProviderURL keyChainAccessGroup:nil];
}

#pragma mark Token retrieval and management

- (CPAToken *)tokenForDomain:(NSString *)domain
{
    NSParameterAssert(domain);
    
    NSString *key = [self keyChainKeyForDomain:domain];
    NSData *tokenData = [self.keyChainStore dataForKey:key];
    return tokenData ? [NSKeyedUnarchiver unarchiveObjectWithData:tokenData] : nil;
}

- (void)requestTokenForDomain:(NSString *)domain withType:(CPATokenType)type completionBlock:(CPATokenCompletionBlock)completionBlock
{
    NSParameterAssert(domain);
    
    // User tokens can be refreshed without requiring the application to be paired again with the user account, provided the previously
    // granted access has not been revoked and the client identifier and secret have not been lost
    CPAToken *token = [self tokenForDomain:domain];
    if (token && token.type == CPATokenTypeUser) {
        [CPAStatelessRequest refreshUserAccessTokenWithAuthorizationProviderURL:self.authorizationProviderURL clientIdentifier:token.clientIdentifier clientSecret:token.clientSecret domain:domain completionBlock:^(NSString *userName, NSString *accessToken, NSString *tokenType, NSString *domainName, NSInteger expiresInSeconds, NSError *error) {
            if (error) {
                // The application has been revoked. Register again
                if ([error.domain isEqualToString:CPAErrorDomain] && error.code == CPAErrorInvalidClient) {
                    [self registerAndRequestTokenForDomain:domain withType:type completionBlock:completionBlock];
                    return;
                }
                
                completionBlock ? completionBlock(nil, error) : nil;
                return;
            }
            
            CPAToken *freshToken = [[CPAToken alloc] initWithValue:accessToken clientIdentifier:token.clientIdentifier clientSecret:token.clientSecret domain:domain];
            freshToken.domainName = domainName;
            freshToken.type = type;
            [self setToken:freshToken forDomain:domain];
            
            completionBlock ? completionBlock(token, nil) : nil;
        }];
    }
    else {
        [self registerAndRequestTokenForDomain:domain withType:type completionBlock:completionBlock];
    }
}

- (void)registerAndRequestTokenForDomain:(NSString *)domain withType:(CPATokenType)type completionBlock:(CPATokenCompletionBlock)completionBlock
{
    NSParameterAssert(domain);
        
    NSString *clientName = [NSBundle mainBundle].infoDictionary[@"CFBundleName"];
    NSAssert(clientName, @"A client name is required");
    
    NSString *softwareIdentifier = [NSBundle mainBundle].bundleIdentifier;
    NSAssert(softwareIdentifier, @"A software identifier is required");
    
    NSString *softwareVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    NSAssert(softwareVersion, @"A software version is required");
    
    [CPAStatelessRequest registerClientWithAuthorizationProviderURL:self.authorizationProviderURL clientName:clientName softwareIdentifier:softwareIdentifier softwareVersion:softwareVersion completionBlock:^(NSString *clientIdentifier, NSString *clientSecret, NSError *error) {
        if (error) {
            completionBlock ? completionBlock(nil, error) : nil;
            return;
        }
        
        // Common token request completion code
        void (^tokenRequestCompletionBlock)(NSString *, NSString *, NSError *) = ^(NSString *accessToken, NSString *domainName, NSError *error) {
            if (error) {
                completionBlock ? completionBlock(nil, error) : nil;
                return;
            }
            
            CPAToken *token = [[CPAToken alloc] initWithValue:accessToken clientIdentifier:clientIdentifier clientSecret:clientSecret domain:domain];
            token.domainName = domainName;
            token.type = type;
            [self setToken:token forDomain:domain];
            
            completionBlock ? completionBlock(token, nil) : nil;
        };
        
        // User token: Request user code first
        if (type == CPATokenTypeUser) {
            [CPAStatelessRequest requestUserCodeWithAuthorizationProviderURL:self.authorizationProviderURL clientIdentifier:clientIdentifier clientSecret:clientSecret domain:domain completionBlock:^(NSString *deviceCode, NSString *userCode, NSURL *verificationURL, NSInteger pollingInterval, NSInteger expiresInSeconds, NSError *error) {
                if (error) {
                    completionBlock ? completionBlock(nil, error) : nil;
                    return;
                }
                
                // Common user token request code
                CPAVoidCompletionBlock userTokenRequestBlock = ^(NSError *error) {
                    if (error) {
                        completionBlock ? completionBlock(nil, error) : nil;
                        return;
                    }
                    
                    [CPAStatelessRequest requestUserAccessTokenWithAuthorizationProviderURL:self.authorizationProviderURL deviceCode:deviceCode clientIdentifier:clientIdentifier clientSecret:clientSecret domain:domain completionBlock:^(NSString *userName, NSString *accessToken, NSString *tokenType, NSString *domainName, NSInteger expiresInSeconds, NSError *error) {
                        tokenRequestCompletionBlock(accessToken, domainName, error);
                    }];
                };
                
                // Open verification URL built-in browser
                if (verificationURL) {
                    NSURL *fullVerificationURL = CPAFullVerificationURL(verificationURL, userCode);
                    NSURLRequest *request = [NSURLRequest requestWithURL:fullVerificationURL];
                    CPAWebViewController *webViewController = [[CPAWebViewController alloc] initWithRequest:request];
                    
                    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
                    webViewController.callbackURLBlock = ^(NSURL *callbackURL) {
                        [rootViewController dismissViewControllerAnimated:YES completion:nil];
                        
                        NSError *callbackError = CPAErrorFromCallbackURL(callbackURL);
                        userTokenRequestBlock(callbackError);
                    };
                    
                    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:webViewController];
                    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
                    [rootViewController presentViewController:navigationController animated:YES completion:nil];
                }
                // If no verification URL is received, this means that single sign-on is provided by the authorization provider when connecting
                // to a new service provider affiliated to it (see 8.2.2.3 in spec). Proceed with token retrieval
                else {
                    userTokenRequestBlock(nil);
                }
            }];
        }
        // Client token
        else {
            [CPAStatelessRequest requestClientAccessTokenWithAuthorizationProviderURL:self.authorizationProviderURL clientIdentifier:clientIdentifier clientSecret:clientSecret domain:domain completionBlock:^(NSString *accessToken, NSString *tokenType, NSString *domainName, NSInteger expiresInSeconds, NSError *error) {
                tokenRequestCompletionBlock(accessToken, domainName, error);
            }];
        }
    }];
}

- (void)discardTokenForDomain:(NSString *)domain
{
    NSParameterAssert(domain);
    
    NSString *key = [self keyChainKeyForDomain:domain];
    [self.keyChainStore removeItemForKey:key];
}

#pragma mark Keychain storage management

- (NSString *)keyChainKeyForDomain:(NSString *)domain
{
    NSParameterAssert(domain);
    
    // FIXME: If we want to support multiple users per application, the key should also contain a reference
    //        to a reliable user identifier. Currently only the user display name can be retrieved (user_name),
    //        which is sadly not reliable enough since it might change
    return [NSString stringWithFormat:@"%@_%@", self.authorizationProviderURL.absoluteString, domain];
}

- (void)setToken:(CPAToken *)token forDomain:(NSString *)domain
{
    NSParameterAssert(domain);
    
    NSData *tokenData = [NSKeyedArchiver archivedDataWithRootObject:token];
    NSString *key = [self keyChainKeyForDomain:domain];
    [self.keyChainStore setData:tokenData forKey:key];
}

@end

static NSURL *CPAFullVerificationURL(NSURL *verificationURL, NSString *userCode)
{
    // To automatically enter the user code, we need to add a user_code and a redirect_uri paramters to the URL. The redirect URI could be
    // used as a way to return to the application if Safari was used to enter credentials. This safe way of supplying credentials sadly leads
    // to App Store rejection nowadays (see http://furbo.org/2014/09/24/in-app-browsers-considered-harmful/, for example), an in-app web
    // browser is therefore used
    NSURLComponents *callbackURLComponents = [[NSURLComponents alloc] init];
    callbackURLComponents.scheme = CPAWebViewCallbackURLScheme;
    callbackURLComponents.host = @"verification";
    NSString *callbackURLString = callbackURLComponents.URL.absoluteString;
    
    // .query automatically adds percent encoding
    NSURLComponents *fullVerificationURLComponents = [NSURLComponents componentsWithURL:verificationURL resolvingAgainstBaseURL:NO];
    fullVerificationURLComponents.query = [NSString stringWithFormat:@"user_code=%@&redirect_uri=%@", userCode, callbackURLString];
    
    return fullVerificationURLComponents.URL;
}

static NSError *CPAErrorFromCallbackURL(NSURL *callbackURL)
{
    // TODO: When minimal supported version is iOS 8, can use -[NSURLComponents queryItems]. The code below does not handle
    //       all cases correctly (e.g. parameters containing = when percent decoded) but should suffice
    NSURLComponents *URLComponents = [NSURLComponents componentsWithURL:callbackURL resolvingAgainstBaseURL:NO];
    NSArray *queryItemStrings = [URLComponents.query componentsSeparatedByString:@"&"];
    
    NSMutableDictionary *queryItems = [NSMutableDictionary dictionary];
    for (NSString *queryItemString in queryItemStrings) {
        NSArray *queryItemComponents = [queryItemString componentsSeparatedByString:@"="];
        NSString *key = [queryItemComponents firstObject];
        NSString *value = [queryItemComponents lastObject];
        
        if (key && value) {
            [queryItems setObject:value forKey:key];
        }
    }
    
    NSString *errorIdentifier = queryItems[@"info"];
    return errorIdentifier ? CPAErrorFromIdentifier(errorIdentifier) : nil;
}
