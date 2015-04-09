//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "EBUCrossPlatformAuthenticationProvider.h"

#import <UIKit/UIKit.h>

// TODO: Friendly CFNetwork errors
// TODO: Store tokens in keychain separately for domain / client or user
// TODO: Deal with localization (use custom macro accessing the library bundle)
// TODO: Prevent multiple requests

// Variable and constant declarations
static EBUCrossPlatformAuthenticationProvider *s_defaultAuthenticationProvider = nil;
NSString * const EBUAuthenticationErrorDomain = @"ch.ebu.cpa.error";

// Function declarations
static EBUAuthenticationErrorCode EBUAuthenticationErrorCodeForIdentifier(NSString *errorIdentifier);
static NSString *EBULocalizedErrorDescriptionForCode(EBUAuthenticationErrorCode errorCode);
static NSString *EBULocalizedErrorDescriptionForIdentifier(NSString *errorIdentifier);
static NSError *EBUErrorFromIdentifier(NSString *errorIdentifier);

@interface EBUCrossPlatformAuthenticationProvider ()

@property (nonatomic) NSURL *authorizationProviderURL;

@end

@implementation EBUCrossPlatformAuthenticationProvider

#pragma mark Class methods

+ (EBUCrossPlatformAuthenticationProvider *)setDefaultAuthenticationProvider:(EBUCrossPlatformAuthenticationProvider *)authenticationProvider
{
    EBUCrossPlatformAuthenticationProvider *previousAuthenticationProvider = s_defaultAuthenticationProvider;
    s_defaultAuthenticationProvider = authenticationProvider;
    return previousAuthenticationProvider;
}

+ (instancetype)defaultAuthenticationProvider
{
    return s_defaultAuthenticationProvider;
}

#pragma mark Object lifecycle

- (instancetype)initWithAuthorizationProviderURL:(NSURL *)authorizationProviderURL
{
    NSParameterAssert(authorizationProviderURL);
    
    if (self = [super init]) {
        self.authorizationProviderURL = authorizationProviderURL;
    }
    return self;
}

#pragma mark Authentication

- (void)userTokenForDomain:(NSString *)domain withCompletionBlock:(void (^)(NSString *, NSString *, NSError *))completionBlock
{
    NSParameterAssert(domain);
    
    NSString *clientName = [NSBundle mainBundle].infoDictionary[@"CFBundleName"];
    NSString *softwareIdentifier = [NSBundle mainBundle].bundleIdentifier;
    NSString *softwareVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    
    NSAssert(clientName, @"A client name is required");
    NSAssert(softwareIdentifier, @"A software identifier is required");
    NSAssert(softwareVersion, @"A software version is required");
    
    [EBUCrossPlatformAuthenticationProvider registerClientWithAuthorizationProviderURL:self.authorizationProviderURL clientName:clientName softwareIdentifier:softwareIdentifier softwareVersion:softwareVersion completionBlock:^(NSString *clientIdentifier, NSString *clientSecret, NSError *error) {
        if (error) {
            completionBlock ? completionBlock(nil, nil, error) : nil;
            return;
        }
        
        [EBUCrossPlatformAuthenticationProvider requestUserCodeWithAuthorizationProviderURL:self.authorizationProviderURL clientIdentifier:clientIdentifier clientSecret:clientSecret domain:domain completionBlock:^(NSString *deviceCode, NSString *userCode, NSURL *verificationURL, NSInteger pollingInterval, NSInteger expiresInSeconds, NSError *error) {
            if (error) {
                completionBlock ? completionBlock(nil, nil, error) : nil;
                return;
            }
            
            // Open verification URL in (trusted) Safari. If no verification URL is received, single sign-on is provided by
            // the authorization provider for a new service provider (see 8.2.2.3 in spec)
            if (verificationURL) {
                [[UIApplication sharedApplication] openURL:verificationURL];
                
                // TODO: Workflow should resume when coming back from the browser
            }
            else {
                [EBUCrossPlatformAuthenticationProvider requestUserAccessTokenWithAuthorizationProviderURL:self.authorizationProviderURL deviceCode:deviceCode clientIdentifier:clientIdentifier clientSecret:clientSecret domain:domain completionBlock:^(NSString *userName, NSString *accessToken, NSString *tokenType, NSString *domainName, NSInteger expiresInSeconds, NSError *error) {
                    if (error) {
                        completionBlock ? completionBlock(nil, nil, error) : nil;
                        return;
                    }
                    
                    completionBlock ? completionBlock(accessToken, domainName, nil) : nil;
                }];
            }
        }];
    }];
}

- (void)clientTokenForDomain:(NSString *)domain withCompletionBlock:(void (^)(NSString *, NSString *, NSError *))completionBlock
{
    NSParameterAssert(domain);
    
    NSString *clientName = [NSBundle mainBundle].infoDictionary[@"CFBundleName"];
    NSString *softwareIdentifier = [NSBundle mainBundle].bundleIdentifier;
    NSString *softwareVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    
    NSAssert(clientName, @"A client name is required");
    NSAssert(softwareIdentifier, @"A software identifier is required");
    NSAssert(softwareVersion, @"A software version is required");
    
    [EBUCrossPlatformAuthenticationProvider registerClientWithAuthorizationProviderURL:self.authorizationProviderURL clientName:clientName softwareIdentifier:softwareIdentifier softwareVersion:softwareVersion completionBlock:^(NSString *clientIdentifier, NSString *clientSecret, NSError *error) {
        if (error) {
            completionBlock ? completionBlock(nil, nil, error) : nil;
            return;
        }
        
        [EBUCrossPlatformAuthenticationProvider requestClientAccessTokenWithAuthorizationProviderURL:self.authorizationProviderURL clientIdentifier:clientIdentifier clientSecret:clientSecret domain:domain completionBlock:^(NSString *accessToken, NSString *tokenType, NSString *domainName, NSInteger expiresInSeconds, NSError *error) {
            if (error) {
                completionBlock ? completionBlock(nil, nil, error) : nil;
                return;
            }
            
            completionBlock ? completionBlock(accessToken, domainName, nil) : nil;
        }];
    }];
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
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                completionBlock ? completionBlock(nil, nil, error) : nil;
                return;
            }
            
            NSError *parseError = nil;
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
            if (parseError) {
                completionBlock ? completionBlock(nil, nil, parseError) : nil;
                return;
            }
            
            NSString *errorIdentifier = responseDictionary[@"error"];
            if (errorIdentifier) {
                NSError *responseError = EBUErrorFromIdentifier(errorIdentifier);
                completionBlock ? completionBlock(nil, nil, responseError) : nil;
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
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                completionBlock ? completionBlock(nil, nil, nil, 0, 0, error) : nil;
                return;
            }
            
            NSError *parseError = nil;
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
            if (parseError) {
                completionBlock ? completionBlock(nil, nil, nil, 0, 0, parseError) : nil;
                return;
            }
            
            NSString *errorIdentifier = responseDictionary[@"error"];
            if (errorIdentifier) {
                NSError *responseError = EBUErrorFromIdentifier(errorIdentifier);
                completionBlock ? completionBlock(nil, nil, nil, 0, 0, responseError) : nil;
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
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                completionBlock ? completionBlock(nil, nil, nil, nil, 0, error) : nil;
                return;
            }
            
            NSError *parseError = nil;
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
            if (parseError) {
                completionBlock ? completionBlock(nil, nil, nil, nil, 0, parseError) : nil;
                return;
            }
            
            NSString *errorIdentifier = responseDictionary[@"error"] ?: responseDictionary[@"reason"];
            if (errorIdentifier) {
                NSError *responseError = EBUErrorFromIdentifier(errorIdentifier);
                completionBlock ? completionBlock(nil, nil, nil, nil, 0, responseError) : nil;
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
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                completionBlock ? completionBlock(nil, nil, nil, 0, nil) : nil;
                return;
            }
            
            NSError *parseError = nil;
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
            if (parseError) {
                completionBlock ? completionBlock(nil, nil, nil, 0, parseError) : nil;
                return;
            }
            
            NSString *errorIdentifier = responseDictionary[@"error"];
            if (errorIdentifier) {
                NSError *responseError = EBUErrorFromIdentifier(errorIdentifier);
                completionBlock ? completionBlock(nil, nil, nil, 0, responseError) : nil;
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

#pragma mark Functions

static EBUAuthenticationErrorCode EBUAuthenticationErrorCodeForIdentifier(NSString *errorIdentifier)
{
    static NSDictionary *s_errorCodes;
    static dispatch_once_t s_onceToken;
    dispatch_once(&s_onceToken, ^{
        s_errorCodes = @{ @"invalid_request" : @(EBUAuthenticationErrorInvalidRequest),
                          @"invalid_client" : @(EBUAuthenticationErrorInvalidClient),
                          @"slow_down" : @(EBUAuthenticationErrorTooFast),
                          @"authorization_pending" : @(EBUAuthenticationErrorPendingAuthorization) };
    });
    
    NSNumber *errorCode = s_errorCodes[errorIdentifier];
    return errorCode ? [errorCode integerValue] : EBUAuthenticationErrorUnknown;
}

static NSString *EBULocalizedErrorDescriptionForCode(EBUAuthenticationErrorCode errorCode)
{
    static NSDictionary *s_localizedErrorDescriptions;
    static dispatch_once_t s_onceToken;
    dispatch_once(&s_onceToken, ^{
        s_localizedErrorDescriptions = @{ @(EBUAuthenticationErrorUnknown) : NSLocalizedString(@"An unknown error has been encountered", nil),
                                          @(EBUAuthenticationErrorInvalidRequest) : NSLocalizedString(@"The request is invalid", nil),
                                          @(EBUAuthenticationErrorInvalidClient) : NSLocalizedString(@"The client is invalid", nil),
                                          @(EBUAuthenticationErrorTooFast) : NSLocalizedString(@"Too many requests are being made", nil),
                                          @(EBUAuthenticationErrorPendingAuthorization) : NSLocalizedString(@"Authorization is still pending", nil) };
    });
    return s_localizedErrorDescriptions[@(errorCode)];
}

static NSString *EBULocalizedErrorDescriptionForIdentifier(NSString *errorIdentifier)
{
    EBUAuthenticationErrorCode errorCode = EBUAuthenticationErrorCodeForIdentifier(errorIdentifier);
    return EBULocalizedErrorDescriptionForCode(errorCode);
}

static NSError *EBUErrorFromIdentifier(NSString *errorIdentifier)
{
    NSCParameterAssert(errorIdentifier);
    
    return [NSError errorWithDomain:EBUAuthenticationErrorDomain
                               code:EBUAuthenticationErrorCodeForIdentifier(errorIdentifier)
                           userInfo:@{ NSLocalizedDescriptionKey : EBULocalizedErrorDescriptionForIdentifier(errorIdentifier) } ];
}