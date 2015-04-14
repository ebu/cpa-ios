//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "CPAToken.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// Types
typedef void (^CPACredentialsPresentationBlock)(UIViewController *viewController, BOOL isPresenting);
typedef void (^CPATokenCompletionBlock)(CPAToken * __nullable token, NSError * __nullable error);

/**
 * Authentication provider managing cross-platform authentication (CPA) with an authorization provider.
 *
 * For more information about CPA, please refer to the technical documentation: https://tech.ebu.ch/docs/tech/tech3366.pdf
 *
 * An authorization provider delivers tokens associating applications with an identity. Two modes are available:
 *   - client mode (unauthenticated association): An anonymous identity is created and the application is associated with it
 *   - user mode (authenticated associated): The application is linked with a user account, which requires the user to enter
 *     her credentials on some web page
 *
 * When an application has been successfully associated, a token is retrieved and stored in the keychain. This token can then
 * be retrieved to access other services on behalf of the identity. Note that a token might expire. If this is the case,
 * you can always retrieve a new one from the authorization provider.
 *
 * You can instantiate as many providers as required. In most cases a single provider should suffice, which you can 
 * instantiate and conveniently install as default provider by calling +setDefaultProvider:
 *
 * The authentication provider is intended to be used from the main application thread. Using it from any other thread
 * results in undefined behavior.
 */
@interface CPAProvider : NSObject

/**
 * Set the default authentication provider, returning the previously installed one (if any)
 */
+ (nullable CPAProvider *)setDefaultProvider:(nullable CPAProvider *)provider;

/**
 * Return the currently set authentication provider, nil if none
 */
+ (nullable CPAProvider *)defaultProvider;

/**
 * Create an authentication provider connecting to the specified authorization provider URL (mandatory), and sharing tokens
 * within a given key chain group (if set to nil, no group sharing is made)
 */
- (instancetype)initWithAuthorizationProviderURL:(NSURL *)authorizationProviderURL
                             keyChainAccessGroup:(nullable NSString *)keyChainAccessGroup NS_DESIGNATED_INITIALIZER;

/**
 * Create an authentication provider connecting to the specified authorization provider URL (mandatory) without
 * keychain group sharing
 */
- (instancetype)initWithAuthorizationProviderURL:(NSURL *)authorizationProviderURL;

/**
 * The associated authorization provider URL
 */
@property (nonatomic, readonly) NSURL *authorizationProviderURL;

/**
 * Return the token locally available for a given domain, nil if none
 */
- (nullable CPAToken *)tokenForDomain:(NSString *)domain;

/**
 * Retrieve a token for the specified domain with a given type. Before calling this method, you should check whether
 * a token is already available locally by calling the -tokenForDomain: method first, and checking its type property
 *
 * If a user token is requested, the user will be redirected to a verification URL to enter her credentials
 *
 * Note that if a token request is performed while a token is already available locally, and if the request is successful, 
 * the previous local token will be replaced.
 *
 * For possible errors, check CPAErrors.h
 */
- (void)requestTokenForDomain:(NSString *)domain withType:(CPATokenType)type completionBlock:(nullable CPATokenCompletionBlock)completionBlock;

/**
 * Same as -requestTokenForDomain:withType:completionBlock:, but providing a way to customise how the credentials view
 * controller is added and removed from the view controller hierarchy, through the credentialsPresentationBlock block. 
 * Use the isPresenting boolean flag to find whether the view controller is being presented or dismissed.
 *
 * If credentialsPresentationBlock is set to nil, the view controller is displayed modally within a navigation controller
 * (as a modal sheet on iPad)
 */
- (void)requestTokenForDomain:(NSString *)domain
                     withType:(CPATokenType)type
 credentialsPresentationBlock:(nullable CPACredentialsPresentationBlock)credentialsPresentationBlock
              completionBlock:(nullable CPATokenCompletionBlock)completionBlock;

/**
 * Discard a locally available token for the given domain, if any
 */
- (void)discardTokenForDomain:(NSString *)domain;

@end

@interface CPAProvider (UnavailableMethods)

- (instancetype)init NS_UNAVAILABLE;

@end
NS_ASSUME_NONNULL_END
