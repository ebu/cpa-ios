//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "EBUToken.h"

#import <Foundation/Foundation.h>

/**
 * Manage cross-platform authentication (CPA) with an authorization provider.
 *
 * For more information about CPA, refer to https://tech.ebu.ch/docs/tech/tech3366.pdf
 *
 * An authorization provider delivers tokens associating applications with an identity. Two modes are available:
 *   - client mode (unauthenticated association): An anonymous identity is created and the application is associated with it
 *   - user mode (authenticated associated): The application is linked with a user account, which requires the user to log in
 *
 * When an application has been successfully associated, a token is retrieved and stored in the keychain. This token can then
 * be used to access other services on behalf of the identity.
 *
 * You can instantiate as many providers as required. In most cases a single provider should suffice, which you can 
 * instantiate and install as default provider by calling +setDefaultAuthenticationProvider:
 *
 * The authentication provider is intended to be used from the main application thread. Using it from any other thread
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
+ (EBUCrossPlatformAuthenticationProvider *)defaultAuthenticationProvider;

/**
 * Call this method from your application delegate - application:openURL:sourceApplication:annotation: method implementation
 * to ensure that the application correctly resumes after the user has entered her credentials in Safari
 */
+ (void)handleURL:(NSURL *)URL;

/**
 * Create an authentication provider connecting to the specified authorization provider URL (mandatory), and sharing tokens
 * within a given key chain group (if set to nil, no group sharing is made)
 */
- (instancetype)initWithAuthorizationProviderURL:(NSURL *)authorizationProviderURL
                               callbackURLScheme:(NSString *)callbackURLScheme
                             keyChainAccessGroup:(NSString *)keyChainAccessGroup NS_DESIGNATED_INITIALIZER;

/**
 * Create an authentication provider connecting to the specified authorization provider URL (mandatory) without
 * keychain group sharing
 */
- (instancetype)initWithAuthorizationProviderURL:(NSURL *)authorizationProviderURL callbackURLScheme:(NSString *)callbackURLScheme;

/**
 * The associated authorization provider URL
 */
@property (nonatomic, readonly) NSURL *authorizationProviderURL;

/**
 * Return the token locally available for a given domain, nil if none
 */
- (EBUToken *)tokenForDomain:(NSString *)domain;

/**
 * Retrieve a token for the specified domain with a given type. Before calling this method, you should check whether
 * an appropriate token is locally already available by calling the -tokenForDomain: method first, and checking its
 * type property
 *
 * If a user token is requested, the user will be redirected to a verification URL to enter her credentials
 *
 * Note that if a token request is performed while a token is already available locally, and if the request is successful, 
 * the previous local token will be replaced.
 *
 * For possible errors, check EBUErrors.h
 */
- (void)requestTokenForDomain:(NSString *)domain withType:(EBUTokenType)type completionBlock:(void (^)(EBUToken *token, NSError *error))completionBlock;

/**
 * Discard a locally available token for the given domain, if any
 */
- (void)discardTokenForDomain:(NSString *)domain;

@end

@interface EBUCrossPlatformAuthenticationProvider (UnavailableMethods)

- (instancetype)init NS_UNAVAILABLE;

@end
