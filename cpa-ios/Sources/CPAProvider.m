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

#import <UIKit/UIKit.h>

// FIXME: Does not work correctly if the app gets killed while in Safari

// Typedefs
typedef void (^CPAVoidCompletionBlock)(NSError *error);

// Globals
static CPAProvider *s_defaultProvider = nil;
static NSMutableDictionary *s_callbackCompletionBlocks = nil;

@interface CPAProvider ()

@property (nonatomic) NSURL *authorizationProviderURL;
@property (nonatomic, copy) NSString *callbackURLScheme;
@property (nonatomic) CPAUICKeyChainStore *keyChainStore;

@end

@implementation CPAProvider

#pragma mark Class methods

+ (void)initialize
{
    if (self != [CPAProvider class]) {
        return;
    }
    
    // Will be used to store completion blocks to be called after a roundtrip to Safari
    s_callbackCompletionBlocks = [NSMutableDictionary dictionary];
}

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

+ (void)handleURL:(NSURL *)URL
{
    CPAVoidCompletionBlock callbackCompletionBlock = s_callbackCompletionBlocks[URL.scheme];
    if (! callbackCompletionBlock) {
        return;
    }
    
    // TODO: When minimal supported version is iOS 8, can use -[NSURLComponents queryItems]. The code below does not handle
    //       all cases correctly (e.g. parameters containing = when percent decoded) but should suffice
    NSURLComponents *URLComponents = [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:NO];
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
    if (errorIdentifier) {
        NSError *error = CPAErrorFromIdentifier(errorIdentifier);
        callbackCompletionBlock(error);
    }
    else {
        callbackCompletionBlock(nil);
    }
    
    [s_callbackCompletionBlocks removeObjectForKey:URL.scheme];
}

#pragma mark Object lifecycle

- (instancetype)initWithAuthorizationProviderURL:(NSURL *)authorizationProviderURL
                               callbackURLScheme:(NSString *)callbackURLScheme
                             keyChainAccessGroup:(NSString *)keyChainAccessGroup
{
    NSParameterAssert(authorizationProviderURL);
    NSParameterAssert(callbackURLScheme);
    
    if (self = [super init]) {
        self.authorizationProviderURL = authorizationProviderURL;
        self.callbackURLScheme = callbackURLScheme;
        
        NSString *serviceIdentifier = [NSBundle mainBundle].bundleIdentifier;
        self.keyChainStore = [CPAUICKeyChainStore keyChainStoreWithService:serviceIdentifier accessGroup:keyChainAccessGroup];
    }
    return self;
}

- (instancetype)initWithAuthorizationProviderURL:(NSURL *)authorizationProviderURL callbackURLScheme:(NSString *)callbackURLScheme
{
    return [self initWithAuthorizationProviderURL:authorizationProviderURL callbackURLScheme:callbackURLScheme keyChainAccessGroup:nil];
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
        
        if (type == CPATokenTypeUser) {
            [CPAStatelessRequest requestUserCodeWithAuthorizationProviderURL:self.authorizationProviderURL clientIdentifier:clientIdentifier clientSecret:clientSecret domain:domain completionBlock:^(NSString *deviceCode, NSString *userCode, NSURL *verificationURL, NSInteger pollingInterval, NSInteger expiresInSeconds, NSError *error) {
                if (error) {
                    completionBlock ? completionBlock(nil, error) : nil;
                    return;
                }
                
                CPAVoidCompletionBlock userTokenRequestBlock = ^(NSError *error) {
                    if (error) {
                        completionBlock ? completionBlock(nil, error) : nil;
                        return;
                    }
                    
                    [CPAStatelessRequest requestUserAccessTokenWithAuthorizationProviderURL:self.authorizationProviderURL deviceCode:deviceCode clientIdentifier:clientIdentifier clientSecret:clientSecret domain:domain completionBlock:^(NSString *userName, NSString *accessToken, NSString *tokenType, NSString *domainName, NSInteger expiresInSeconds, NSError *error) {
                        tokenRequestCompletionBlock(accessToken, domainName, error);
                    }];
                };
                
                // Open verification URL in (trusted) Safari. If no verification URL is received, this means that single sign-on is provided by the authorization
                // provider when connecting to a new service provider affiliated to it (see 8.2.2.3 in spec)
                if (verificationURL) {
                    // Use a callback URL of the form scheme://callback. If the user does not authorize the application, an info parameter will be
                    // appended to it with value user_code:denied
                    NSURLComponents *callbackURLComponents = [[NSURLComponents alloc] init];
                    callbackURLComponents.scheme = self.callbackURLScheme;
                    callbackURLComponents.host = @"callback";
                    NSString *callbackURLString = callbackURLComponents.URL.absoluteString;
                    
                    // .query automatically adds percent encoding
                    NSURLComponents *fullVerificationURLComponents = [NSURLComponents componentsWithURL:verificationURL resolvingAgainstBaseURL:NO];
                    fullVerificationURLComponents.query = [NSString stringWithFormat:@"user_code=%@&redirect_uri=%@", userCode, callbackURLString];
                    
                    [[UIApplication sharedApplication] openURL:fullVerificationURLComponents.URL];
                    
                    // Save for execution when coming back from the browser. A scheme univoquely points at an authentication provider
                    [s_callbackCompletionBlocks setObject:userTokenRequestBlock forKey:self.callbackURLScheme];
                }
                else {
                    userTokenRequestBlock(nil);
                }
            }];
        }
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
