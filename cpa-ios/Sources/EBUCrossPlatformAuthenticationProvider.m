//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "EBUCrossPlatformAuthenticationProvider.h"

#import "EBUErrors+Private.h"
#import "EBUUICKeyChainStore.h"
#import "EBUToken+Private.h"
#import "NSURLSession+EBUJSONExtensions.h"

#import <UIKit/UIKit.h>

// TODO: Deal with localization (use custom macro accessing the library bundle)
// TODO: Prevent multiple requests

// Typedefs
typedef void (^EBUVoidCompletionBlock)(NSError *error);

// Globals
static EBUCrossPlatformAuthenticationProvider *s_defaultAuthenticationProvider = nil;
static NSMutableDictionary *s_callbackCompletionBlocks = nil;

@interface EBUCrossPlatformAuthenticationProvider ()

@property (nonatomic) NSURL *authorizationProviderURL;
@property (nonatomic, copy) NSString *callbackURLScheme;
@property (nonatomic) EBUUICKeyChainStore *keyChainStore;

@end

@implementation EBUCrossPlatformAuthenticationProvider

#pragma mark Class methods

+ (void)initialize
{
    if (self != [EBUCrossPlatformAuthenticationProvider class]) {
        return;
    }
    
    // Will be used to store completion blocks to be called after a roundtrip to Safari
    s_callbackCompletionBlocks = [NSMutableDictionary dictionary];
}

+ (EBUCrossPlatformAuthenticationProvider *)setDefaultAuthenticationProvider:(EBUCrossPlatformAuthenticationProvider *)authenticationProvider
{
    EBUCrossPlatformAuthenticationProvider *previousAuthenticationProvider = s_defaultAuthenticationProvider;
    s_defaultAuthenticationProvider = authenticationProvider;
    return previousAuthenticationProvider;
}

+ (EBUCrossPlatformAuthenticationProvider *)defaultAuthenticationProvider
{
    return s_defaultAuthenticationProvider;
}

+ (void)handleURL:(NSURL *)URL
{
    EBUVoidCompletionBlock callbackCompletionBlock = s_callbackCompletionBlocks[URL.scheme];
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
        NSError *error = EBUErrorFromIdentifier(errorIdentifier);
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
        self.keyChainStore = [EBUUICKeyChainStore keyChainStoreWithService:serviceIdentifier accessGroup:keyChainAccessGroup];
    }
    return self;
}

- (instancetype)initWithAuthorizationProviderURL:(NSURL *)authorizationProviderURL callbackURLScheme:(NSString *)callbackURLScheme
{
    return [self initWithAuthorizationProviderURL:authorizationProviderURL callbackURLScheme:callbackURLScheme keyChainAccessGroup:nil];
}

#pragma mark Token retrieval and management

- (EBUToken *)tokenForDomain:(NSString *)domain
{
    NSParameterAssert(domain);
    
    NSString *key = [self keyChainKeyForDomain:domain];
    NSData *tokenData = [self.keyChainStore dataForKey:key];
    return [NSKeyedUnarchiver unarchiveObjectWithData:tokenData];
}

- (void)requestTokenForDomain:(NSString *)domain withType:(EBUTokenType)type completionBlock:(void (^)(EBUToken *, NSError *))completionBlock
{
    NSParameterAssert(domain);
        
    NSString *clientName = [NSBundle mainBundle].infoDictionary[@"CFBundleName"];
    NSAssert(clientName, @"A client name is required");
    
    NSString *softwareIdentifier = [NSBundle mainBundle].bundleIdentifier;
    NSAssert(softwareIdentifier, @"A software identifier is required");
    
    NSString *softwareVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    NSAssert(softwareVersion, @"A software version is required");
    
    [EBUCrossPlatformAuthenticationProvider registerClientWithAuthorizationProviderURL:self.authorizationProviderURL clientName:clientName softwareIdentifier:softwareIdentifier softwareVersion:softwareVersion completionBlock:^(NSString *clientIdentifier, NSString *clientSecret, NSError *error) {
        if (error) {
            completionBlock ? completionBlock(nil, error) : nil;
            return;
        }
        
        void (^tokenRequestCompletionBlock)(NSString *, NSString *, NSError *) = ^(NSString *accessToken, NSString *domainName, NSError *error) {
            if (error) {
                completionBlock ? completionBlock(nil, error) : nil;
                return;
            }
            
            EBUToken *token = [[EBUToken alloc] initWithValue:accessToken domain:domain];
            token.domainName = domainName;
            token.type = type;
            [self setToken:token forDomain:domain];
            
            completionBlock ? completionBlock(token, nil) : nil;
        };
        
        if (type == EBUTokenTypeUser) {
            [EBUCrossPlatformAuthenticationProvider requestUserCodeWithAuthorizationProviderURL:self.authorizationProviderURL clientIdentifier:clientIdentifier clientSecret:clientSecret domain:domain completionBlock:^(NSString *deviceCode, NSString *userCode, NSURL *verificationURL, NSInteger pollingInterval, NSInteger expiresInSeconds, NSError *error) {
                if (error) {
                    completionBlock ? completionBlock(nil, error) : nil;
                    return;
                }
                
                EBUVoidCompletionBlock userTokenRequestBlock = ^(NSError *error) {
                    if (error) {
                        completionBlock ? completionBlock(nil, error) : nil;
                        return;
                    }
                    
                    [EBUCrossPlatformAuthenticationProvider requestUserAccessTokenWithAuthorizationProviderURL:self.authorizationProviderURL deviceCode:deviceCode clientIdentifier:clientIdentifier clientSecret:clientSecret domain:domain completionBlock:^(NSString *userName, NSString *accessToken, NSString *tokenType, NSString *domainName, NSInteger expiresInSeconds, NSError *error) {
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
            [EBUCrossPlatformAuthenticationProvider requestClientAccessTokenWithAuthorizationProviderURL:self.authorizationProviderURL clientIdentifier:clientIdentifier clientSecret:clientSecret domain:domain completionBlock:^(NSString *accessToken, NSString *tokenType, NSString *domainName, NSInteger expiresInSeconds, NSError *error) {
                tokenRequestCompletionBlock(accessToken, domainName, error);
            }];
        }
    }];
}

- (void)discardTokenForDomain:(NSString *)domain
{
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

- (void)setToken:(EBUToken *)token forDomain:(NSString *)domain
{
    NSParameterAssert(domain);
    
    NSData *tokenData = [NSKeyedArchiver archivedDataWithRootObject:token];
    NSString *key = [self keyChainKeyForDomain:domain];
    [self.keyChainStore setData:tokenData forKey:key];
}

#pragma mark Stateless authentication methods

+ (void)registerClientWithAuthorizationProviderURL:(NSURL *)authorizationProviderURL
                                        clientName:(NSString *)clientName
                                softwareIdentifier:(NSString *)softwareIdentifier
                                   softwareVersion:(NSString *)softwareVersion
                                   completionBlock:(void (^)(NSString *clientIdentifier, NSString *clientSecret, NSError *error))completionBlock
{
    NSParameterAssert(authorizationProviderURL);
    NSParameterAssert(clientName);
    NSParameterAssert(softwareIdentifier);
    NSParameterAssert(softwareVersion);
    
    NSURL *URL = [authorizationProviderURL URLByAppendingPathComponent:@"register"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *requestDictionary = @{ @"client_name" : clientName,
                                         @"software_id" : softwareIdentifier,
                                         @"software_version" : softwareVersion };
    NSData *body = [NSJSONSerialization dataWithJSONObject:requestDictionary options:0 error:NULL];
    [request setHTTPBody:body];
    
    [[[NSURLSession sharedSession] JSONDictionaryTaskWithRequest:request completionHandler:^(NSDictionary *responseDictionary, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                completionBlock ? completionBlock(nil, nil, error) : nil;
                return;
            }
            
            NSString *clientIdentifier = responseDictionary[@"client_id"];
            NSString *clientSecret = responseDictionary[@"client_secret"];
            
            completionBlock ? completionBlock(clientIdentifier, clientSecret, nil) : nil;
        });
    }] resume];
}

+ (void)requestUserCodeWithAuthorizationProviderURL:(NSURL *)authorizationProviderURL
                                   clientIdentifier:(NSString *)clientIdentifier
                                       clientSecret:(NSString *)clientSecret
                                             domain:(NSString *)domain
                                    completionBlock:(void (^)(NSString *deviceCode, NSString *userCode, NSURL *verificationURL, NSInteger pollingIntervalInSeconds, NSInteger expiresInSeconds, NSError *error))completionBlock
{
    NSParameterAssert(authorizationProviderURL);
    NSParameterAssert(clientIdentifier);
    NSParameterAssert(clientSecret);
    NSParameterAssert(domain);
    
    NSURL *URL = [authorizationProviderURL URLByAppendingPathComponent:@"associate"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *requestDictionary = @{ @"client_id" : clientIdentifier,
                                         @"client_secret" : clientSecret,
                                         @"domain" : domain };
    NSData *body = [NSJSONSerialization dataWithJSONObject:requestDictionary options:0 error:NULL];
    [request setHTTPBody:body];
    
    [[[NSURLSession sharedSession] JSONDictionaryTaskWithRequest:request completionHandler:^(NSDictionary *responseDictionary, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                completionBlock ? completionBlock(nil, nil, nil, 0, 0, error) : nil;
                return;
            }
            
            NSString *deviceCode = responseDictionary[@"device_code"];
            NSString *userCode = responseDictionary[@"user_code"];
            NSString *verificationURLString = responseDictionary[@"verification_uri"];
            NSURL *verificationURL = verificationURLString ? [NSURL URLWithString:verificationURLString] : nil;
            NSInteger pollingIntervalInSeconds = [responseDictionary[@"interval"] integerValue];
            NSInteger expiresInSeconds = [responseDictionary[@"expires_in"] integerValue];
            
            completionBlock ? completionBlock(deviceCode, userCode, verificationURL, pollingIntervalInSeconds, expiresInSeconds, nil) : nil;
        });
    }] resume];
}

+ (void)requestUserAccessTokenWithAuthorizationProviderURL:(NSURL *)authorizationProviderURL
                                                deviceCode:(NSString *)deviceCode
                                          clientIdentifier:(NSString *)clientIdentifier
                                              clientSecret:(NSString *)clientSecret
                                                    domain:(NSString *)domain
                                           completionBlock:(void (^)(NSString *userName, NSString *accessToken, NSString *tokenType, NSString *domainName, NSInteger expiresInSeconds, NSError *error))completionBlock
{
    NSParameterAssert(authorizationProviderURL);
    NSParameterAssert(deviceCode);
    NSParameterAssert(clientIdentifier);
    NSParameterAssert(clientSecret);
    NSParameterAssert(domain);
    
    NSURL *URL = [authorizationProviderURL URLByAppendingPathComponent:@"token"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *requestDictionary = @{ @"grant_type" : @"http://tech.ebu.ch/cpa/1.0/device_code",
                                         @"device_code" : deviceCode,
                                         @"client_id" : clientIdentifier,
                                         @"client_secret" : clientSecret,
                                         @"domain" : domain };
    NSData *body = [NSJSONSerialization dataWithJSONObject:requestDictionary options:0 error:NULL];
    [request setHTTPBody:body];
    
    [[[NSURLSession sharedSession] JSONDictionaryTaskWithRequest:request completionHandler:^(NSDictionary *responseDictionary, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                completionBlock ? completionBlock(nil, nil, nil, nil, 0, error) : nil;
                return;
            }
            
            NSString *userName = responseDictionary[@"user_name"];
            NSString *accessToken = responseDictionary[@"access_token"];
            NSString *tokenType = responseDictionary[@"token_type"];
            NSString *domainName = responseDictionary[@"domain_name"];
            NSInteger expiresInSeconds = [responseDictionary[@"expires_in"] integerValue];
            
            completionBlock ? completionBlock(userName, accessToken, tokenType, domainName, expiresInSeconds, nil) : nil;
        });
    }] resume];
}

+ (void)requestClientAccessTokenWithAuthorizationProviderURL:(NSURL *)authorizationProviderURL
                                            clientIdentifier:(NSString *)clientIdentifier
                                                clientSecret:(NSString *)clientSecret
                                                      domain:(NSString *)domain
                                             completionBlock:(void (^)(NSString *accessToken, NSString *tokenType, NSString *domainName, NSInteger expiresInSeconds, NSError *error))completionBlock
{
    NSParameterAssert(authorizationProviderURL);
    NSParameterAssert(clientIdentifier);
    NSParameterAssert(clientSecret);
    NSParameterAssert(domain);
    
    NSURL *URL = [authorizationProviderURL URLByAppendingPathComponent:@"token"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *requestDictionary = @{ @"grant_type" : @"http://tech.ebu.ch/cpa/1.0/client_credentials",
                                         @"client_id" : clientIdentifier,
                                         @"client_secret" : clientSecret,
                                         @"domain" : domain };
    NSData *body = [NSJSONSerialization dataWithJSONObject:requestDictionary options:0 error:NULL];
    [request setHTTPBody:body];
    
    [[[NSURLSession sharedSession] JSONDictionaryTaskWithRequest:request completionHandler:^(NSDictionary *responseDictionary, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                completionBlock ? completionBlock(nil, nil, nil, 0, nil) : nil;
                return;
            }
            
            NSString *accessToken = responseDictionary[@"access_token"];
            NSString *tokenType = responseDictionary[@"token_type"];
            NSString *domainName = responseDictionary[@"domain_display_name"];
            NSInteger expiresInSeconds = [responseDictionary[@"expires_in"] integerValue];
            
            completionBlock ? completionBlock(accessToken, tokenType, domainName, expiresInSeconds, nil) : nil;
        });
    }] resume];
}

@end
