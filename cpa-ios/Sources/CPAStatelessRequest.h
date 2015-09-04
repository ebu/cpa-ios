//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "CPANullability.h"

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// Types
typedef void (^CPAClientRegistrationCompletionBlock)(NSString * __nullable clientIdentifier, NSString * __nullable clientSecret, NSError * __nullable error);
typedef void (^CPAUserCodeRequestCompletionBlock)(NSString * __nullable deviceCode, NSString * __nullable userCode, NSURL * __nullable verificationURL, NSInteger pollingIntervalInSeconds, NSInteger expiresInSeconds, NSError * __nullable error);
typedef void (^CPATokenRequestCompletionBlock)(NSString * __nullable userName, NSString * __nullable accessToken, NSString * __nullable tokenType, NSString * __nullable domainName, NSInteger expiresInSeconds, NSError * __nullable error);

/**
 * Stateless requests, for implementation purposes only
 */
@interface CPAStatelessRequest : NSObject

/**
 * To register with the authorization provider, the client makes a request to the authorization provider's registration endpoint, 
 * /register. In response, the authorization provider assigns a unique client identifier and an associated client secret
 */
+ (void)registerClientWithAuthorizationProviderURL:(NSURL *)authorizationProviderURL
                                        clientName:(NSString *)clientName
                                softwareIdentifier:(NSString *)softwareIdentifier
                                   softwareVersion:(NSString *)softwareVersion
                                   completionBlock:(CPAClientRegistrationCompletionBlock)completionBlock;

/**
 * To associate a client with a user account, the client first makes a request to the authorization provider's association endpoint,
 * /associate. In response, the authorization provider assigns a user verification code and returns this to the client together with 
 * a URI that the user should visit in order to authenticate himself and input the user code to pair their client with their account
 */
+ (void)requestCodeWithAuthorizationProviderURL:(NSURL *)authorizationProviderURL
                               clientIdentifier:(NSString *)clientIdentifier
                                   clientSecret:(NSString *)clientSecret
                                         domain:(NSString *)domain
                                completionBlock:(CPAUserCodeRequestCompletionBlock)completionBlock;

/**
 * To obtain an access token, the client makes a request to the authorization provider's token endpoint, /token. In user mode, a token
 * will be obtained after the user has visited the verification URL, entered her credentials and authorized the device
 */
+ (void)requestUserTokenWithAuthorizationProviderURL:(NSURL *)authorizationProviderURL
                                          deviceCode:(NSString *)deviceCode
                                    clientIdentifier:(NSString *)clientIdentifier
                                        clientSecret:(NSString *)clientSecret
                                              domain:(NSString *)domain
                                     completionBlock:(CPATokenRequestCompletionBlock)completionBlock;

/**
 * To obtain an access token, the client makes a request to the authorization provider's token endpoint, /token. In client mode, since
 * the authorization provider doesn't require any further action on the part of the user, the authorization provider can automatically
 * issue a token
 */
+ (void)requestClientTokenWithAuthorizationProviderURL:(NSURL *)authorizationProviderURL
                                      clientIdentifier:(NSString *)clientIdentifier
                                          clientSecret:(NSString *)clientSecret
                                                domain:(NSString *)domain
                                       completionBlock:(CPATokenRequestCompletionBlock)completionBlock;

/**
 * To replace an expired client or user token with a new access token, the client makes a HTTP POST request to the authorization 
 * provider's /token endpoint
 */
+ (void)refreshTokenWithAuthorizationProviderURL:(NSURL *)authorizationProviderURL
                                clientIdentifier:(NSString *)clientIdentifier
                                    clientSecret:(NSString *)clientSecret
                                          domain:(NSString *)domain
                                 completionBlock:(CPATokenRequestCompletionBlock)completionBlock;

@end

NS_ASSUME_NONNULL_END
