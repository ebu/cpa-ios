//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import <Foundation/Foundation.h>

/**
 * Authentication error codes
 */
typedef NS_ENUM(NSInteger, EBUAuthenticationErrorCode) {
    EBUAuthenticationErrorUnknown,                  // An unknown error has occurred
    EBUAuthenticationErrorInvalidRequest,           // The request is invalid
    EBUAuthenticationErrorInvalidClient,            // The client is invalid
    EBUAuthenticationErrorTooFast,                  // Requests are made too fast. Slow down
    EBUAuthenticationErrorPendingAuthorization      // Authorization has not yet been made
};

/**
 * Common domain of authentication errors
 */
OBJC_EXPORT NSString * const EBUAuthenticationErrorDomain;

/**
 * Manage cross-platform authentication (CPA) with an authorization provider.
 *
 * For more information about CPA, refer to https://tech.ebu.ch/docs/tech/tech3366.pdf
 *
 * An authorization provider delivers tokens associating devices with an identity. Two modes are available:
 *   - client mode (unauthenticated association): An anonymous identity is created and the device is associated with it
 *   - user mode (authenticated associated): The device is linked with a user account, which requires the user to log in
 *
 * When a device has been successfully associated, a token is retrieved and stored in the keychain. This token can then
 * be used to access other services on behalf of the identity.
 *
 * You can instantiate as many providers as required. In most cases a single provider should suffice, which you can 
 * instantiate and install as default provider by calling +setDefaultCrossPlatformAuthenticationProvider:
 *
 * This authentication provider is intended to be used from the main application thread. Using it from other threads
 * results in undefined behavior.
 */
@interface EBUCrossPlatformAuthenticationProvider : NSObject

/**
 * Set the default authentication provider, returning the previously installed one (if any)
 */
+ (EBUCrossPlatformAuthenticationProvider *)setDefaultAuthenticationProvider:(EBUCrossPlatformAuthenticationProvider *)authenticationProvider;

/**
 * Return the currently set authentication provider, nil if none
 */
+ (instancetype)defaultAuthenticationProvider;

/**
 * Create an authentication provider connecting to the specified authorization provider URL (mandatory)
 */
- (instancetype)initWithAuthorizationProviderURL:(NSURL *)authorizationProviderURL NS_DESIGNATED_INITIALIZER;

/**
 * The associated authorization provider URL
 */
@property (nonatomic, readonly) NSURL *authorizationProviderURL;

/**
 * Request a token associated with a user account. During the process of token retrieval, and if the device is not already associated
 * with the account, the user will be redirected to a URL for authentication. Call -resume on the task to start it
 *
 * If a valid token is available from the keychain, it is directly returned
 */
- (void)userTokenForDomain:(NSString *)domain withCompletionBlock:(void (^)(NSString *accessToken, NSString *domainName, NSError *error))completionBlock;

/**
 * Request a token not associated with any user account. Call -resume on the task to start it
 *
 * If a valid token is available from the keychain, it is directly returned
 */
- (void)clientTokenForDomain:(NSString *)domain withCompletionBlock:(void (^)(NSString *accessToken, NSString *domainName, NSError *error))completionBlock;

@end

@interface EBUCrossPlatformAuthenticationProvider (UnavailableMethods)

- (instancetype)init NS_UNAVAILABLE;

@end
