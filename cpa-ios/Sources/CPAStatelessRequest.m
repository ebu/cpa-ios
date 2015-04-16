//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "CPAStatelessRequest.h"

#import "NSURLSession+CPAExtensions.h"

@implementation CPAStatelessRequest

+ (void)registerClientWithAuthorizationProviderURL:(NSURL *)authorizationProviderURL
                                        clientName:(NSString *)clientName
                                softwareIdentifier:(NSString *)softwareIdentifier
                                   softwareVersion:(NSString *)softwareVersion
                                   completionBlock:(CPAClientRegistrationCompletionBlock)completionBlock
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
    
    [[[NSURLSession sharedSession] cpa_JSONDictionaryTaskWithRequest:request completionHandler:^(NSDictionary *responseDictionary, NSURLResponse *response, NSError *error) {
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

+ (void)requestCodeWithAuthorizationProviderURL:(NSURL *)authorizationProviderURL
                               clientIdentifier:(NSString *)clientIdentifier
                                   clientSecret:(NSString *)clientSecret
                                         domain:(NSString *)domain
                                completionBlock:(CPAUserCodeRequestCompletionBlock)completionBlock
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
    
    [[[NSURLSession sharedSession] cpa_JSONDictionaryTaskWithRequest:request completionHandler:^(NSDictionary *responseDictionary, NSURLResponse *response, NSError *error) {
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
                                           completionBlock:(CPAUserAccessTokenRequestCompletionBlock)completionBlock
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
    
    [[[NSURLSession sharedSession] cpa_JSONDictionaryTaskWithRequest:request completionHandler:^(NSDictionary *responseDictionary, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                completionBlock ? completionBlock(nil, nil, nil, nil, 0, error) : nil;
                return;
            }
            
            NSString *userName = responseDictionary[@"user_name"];
            NSString *accessToken = responseDictionary[@"access_token"];
            NSString *tokenType = responseDictionary[@"token_type"];
            NSString *domainName = responseDictionary[@"domain_display_name"];
            NSInteger expiresInSeconds = [responseDictionary[@"expires_in"] integerValue];
            
            completionBlock ? completionBlock(userName, accessToken, tokenType, domainName, expiresInSeconds, nil) : nil;
        });
    }] resume];
}

+ (void)requestClientAccessTokenWithAuthorizationProviderURL:(NSURL *)authorizationProviderURL
                                            clientIdentifier:(NSString *)clientIdentifier
                                                clientSecret:(NSString *)clientSecret
                                                      domain:(NSString *)domain
                                             completionBlock:(CPAClientAccessTokenRequestCompletionBlock)completionBlock
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
    
    [[[NSURLSession sharedSession] cpa_JSONDictionaryTaskWithRequest:request completionHandler:^(NSDictionary *responseDictionary, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                completionBlock ? completionBlock(nil, nil, nil, 0, error) : nil;
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
