//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "EBUCrossPlatformAuthenticationProvider.h"

static EBUCrossPlatformAuthenticationProvider *s_defaultCrossPlatformAuthenticationProvider = nil;

@interface EBUCrossPlatformAuthenticationProvider ()

@property (nonatomic) NSURL *authorizationProviderURL;

@end

@implementation EBUCrossPlatformAuthenticationProvider

#pragma mark Class methods

+ (EBUCrossPlatformAuthenticationProvider *)setDefaultCrossPlatformAuthenticationProvider:(EBUCrossPlatformAuthenticationProvider *)crossPlatformAuthenticationProvider
{
    EBUCrossPlatformAuthenticationProvider *previousDefaultCrossPlatformAuthenticationProvider = s_defaultCrossPlatformAuthenticationProvider;
    s_defaultCrossPlatformAuthenticationProvider = crossPlatformAuthenticationProvider;
    return previousDefaultCrossPlatformAuthenticationProvider;
}

+ (instancetype)defaultCrossPlatformAuthenticationProvider
{
    return s_defaultCrossPlatformAuthenticationProvider;
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

- (NSURLSessionTask *)userTokenWithCompletionBlock:(void (^)(NSString *accessToken, NSError *error))completionBlock
{
    // TODO: Implement
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSURLSessionTask *)clientTokenWithCompletionBlock:(void (^)(NSString *accessToken, NSError *error))completionBlock
{
    // TODO: Implement
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark Stateless authentication methods

+ (NSURLSessionTask *)registerClientWithAuthorizationProviderURL:(NSURL *)authorizationProviderURL
                                                      clientName:(NSString *)clientName
                                              softwareIdentifier:(NSString *)softwareIdentifier
                                                 softwareVersion:(NSString *)sotfwareVersion
                                                 completionBlock:(void (^)(NSString *clientIdentifier, NSString *clientSecret, NSError *error))completionBlock
{
    // TODO: Implement
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

+ (NSURLSessionTask *)requestUserCodeWithAuthorizationProviderURL:(NSURL *)authorizationProviderURL
                                                 clientIdentifier:(NSString *)clientIdentifier
                                                     clientSecret:(NSString *)clientSecret
                                                           domain:(NSString *)domain
                                                  completionBlock:(void (^)(NSString *deviceCode, NSString *userCode, NSURL *verificationURL, NSInteger expiresInSeconds, NSError *error))completionBlock
{
    // TODO: Implement
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

+ (NSURLSessionTask *)requestUserAccessTokenWithAuthorizationProviderURL:(NSURL *)authorizationProviderURL
                                                              deviceCode:(NSString *)deviceCode
                                                        clientIdentifier:(NSString *)clientIdentifier
                                                            clientSecret:(NSString *)clientSecret
                                                                  domain:(NSString *)domain
                                                         completionBlock:(void (^)(NSString *userName, NSString *accessToken, NSString *tokenType, NSString *domainName, NSInteger expiresInSeconds, NSError *error))completionBlock
{
    // TODO: Implement
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

+ (NSURLSessionTask *)requestClientAccessTokenWithAuthorizationProviderURL:(NSURL *)authorizationProviderURL
                                                          clientIdentifier:(NSString *)clientIdentifier
                                                              clientSecret:(NSString *)clientSecret
                                                                    domain:(NSString *)domain
                                                           completionBlock:(void (^)(NSString *accessToken, NSString *tokenType, NSString *domainName, NSInteger expiresInSeconds, NSError *error))completionBlock
{
    // TODO: Implement
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
