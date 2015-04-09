//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "EBUCrossPlatformAuthenticationProvider.h"

static EBUCrossPlatformAuthenticationProvider *s_defaultAuthenticationProvider = nil;

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

- (NSURLSessionTask *)userTokenWithCompletionBlock:(void (^)(NSString *accessToken, NSError *error))completionBlock
{
    // TODO: Implement
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSURLSessionTask *)clientTokenWithCompletionBlock:(void (^)(NSString *accessToken, NSError *error))completionBlock
{
    NSString *clientName = [NSBundle mainBundle].infoDictionary[@"CFBundleName"];
    NSString *softwareIdentifier = [NSBundle mainBundle].bundleIdentifier;
    NSString *softwareVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    
    NSAssert(clientName, @"A client name is required");
    NSAssert(softwareIdentifier, @"A software identifier is required");
    NSAssert(softwareVersion, @"A software version is required");
    
    return [EBUCrossPlatformAuthenticationProvider registerClientWithAuthorizationProviderURL:self.authorizationProviderURL clientName:clientName softwareIdentifier:softwareIdentifier softwareVersion:softwareVersion completionBlock:^(NSString *clientIdentifier, NSString *clientSecret, NSError *error) {
        NSLog(@"Client id: %@, client secret: %@, error: %@", clientIdentifier, clientSecret, error);
    }];
}

#pragma mark Stateless authentication methods

+ (NSURLSessionTask *)registerClientWithAuthorizationProviderURL:(NSURL *)authorizationProviderURL
                                                      clientName:(NSString *)clientName
                                              softwareIdentifier:(NSString *)softwareIdentifier
                                                 softwareVersion:(NSString *)softwareVersion
                                                 completionBlock:(void (^)(NSString *clientIdentifier, NSString *clientSecret, NSError *error))completionBlock
{
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
    
    return [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
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
        
        completionBlock ? completionBlock(responseDictionary[@"client_id"], responseDictionary[@"client_secret"], nil) : nil;
    }];
    
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
