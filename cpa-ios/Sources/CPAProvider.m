//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "CPAProvider.h"

#import "CPAIdentity+Private.h"
#import "CPAErrors+Private.h"
#import "CPAStatelessRequest.h"
#import "CPAUICKeyChainStore.h"
#import "CPAToken+Private.h"
#import "CPAAuthorizationViewController.h"
#import "NSBundle+CPAExtensions.h"

#import <UIKit/UIKit.h>

// Typedefs
typedef void (^CPAVoidCompletionBlock)(NSError *error);
typedef void (^CPATokenInformationCompletionBlock)(NSString *userName, NSString *accessToken, NSString *domainName, NSInteger expiresInSeconds, NSError *error);

// Globals
static CPAProvider *s_defaultProvider = nil;

@interface CPAProvider ()

@property (nonatomic) NSURL *authorizationProviderURL;
@property (nonatomic) CPAUICKeyChainStore *keyChainStore;

@property (nonatomic, readonly, copy) NSString *keyChainIdentifier;

@end

@implementation CPAProvider

#pragma mark Class methods

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

#pragma mark Object lifecycle

- (instancetype)initWithAuthorizationProviderURL:(NSURL *)authorizationProviderURL
                             keyChainAccessGroup:(NSString *)keyChainAccessGroup
{
    NSParameterAssert(authorizationProviderURL);
    
    if (self = [super init]) {
        self.authorizationProviderURL = authorizationProviderURL;
        
        NSString *serviceIdentifier = [NSBundle mainBundle].bundleIdentifier;
        self.keyChainStore = [CPAUICKeyChainStore keyChainStoreWithService:serviceIdentifier accessGroup:keyChainAccessGroup];
    }
    return self;
}

- (instancetype)initWithAuthorizationProviderURL:(NSURL *)authorizationProviderURL
{
    return [self initWithAuthorizationProviderURL:authorizationProviderURL keyChainAccessGroup:nil];
}

#pragma mark Token retrieval

- (CPAToken *)tokenForDomain:(NSString *)domain
{
    NSParameterAssert(domain);
    
    NSString *key = [self keyChainKeyForDomain:domain];
    NSData *tokenData = [self.keyChainStore dataForKey:key];
    return tokenData ? [NSKeyedUnarchiver unarchiveObjectWithData:tokenData] : nil;
}

- (void)requestTokenForDomain:(NSString *)domain withType:(CPATokenType)type completionBlock:(CPATokenCompletionBlock)completionBlock
{
    [self requestTokenForDomain:domain withType:type credentialsPresentationBlock:nil completionBlock:completionBlock];
}

- (void)requestTokenForDomain:(NSString *)domain
                     withType:(CPATokenType)type
 credentialsPresentationBlock:(CPACredentialsPresentationBlock)credentialsPresentationBlock
              completionBlock:(CPATokenCompletionBlock)completionBlock
{
    NSParameterAssert(domain);
    
    // Default: Modal presentation, wrapped in a navigation controller, with a cancel button at the top left
    if (! credentialsPresentationBlock) {
        credentialsPresentationBlock = ^(UIViewController *viewController, BOOL isPresenting) {
            viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:CPALocalizedString(@"Cancel", nil)
                                                                                               style:UIBarButtonItemStylePlain
                                                                                              target:self
                                                                                              action:@selector(closeCredentials:)];
            
            UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
            if (isPresenting) {
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
                navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
                [rootViewController presentViewController:navigationController animated:YES completion:nil];
            }
            else {
                [rootViewController dismissViewControllerAnimated:YES completion:nil];
            }
        };
    }
    
    [self registerAndRequestTokenForDomain:domain withType:type credentialsPresentationBlock:credentialsPresentationBlock completionBlock:^(NSString *userName, NSString *accessToken, NSString *domainName, NSInteger expiresInSeconds, NSError *error) {
        if (error) {
            completionBlock ? completionBlock(nil, error) : nil;
            return;
        }
        
        NSDate *expirationDate = [[NSDate date] dateByAddingTimeInterval:expiresInSeconds];
        CPAToken *token = [[CPAToken alloc] initWithValue:accessToken
                                                   domain:domain
                                               domainName:domainName
                                                 userName:userName
                                           expirationDate:expirationDate];
        [self setToken:token forDomain:domain];
        
        completionBlock ? completionBlock(token, nil) : nil;
    }];
}

/**
 * Create a new identity if needed and obtain a client / user token for the specified domain on its behalf
 */
- (void)registerAndRequestTokenForDomain:(NSString *)domain
                                withType:(CPATokenType)type
            credentialsPresentationBlock:(CPACredentialsPresentationBlock)credentialsPresentationBlock
                         completionBlock:(CPATokenInformationCompletionBlock)completionBlock
{
    // If an identity has already been retrieved for this provider, reuse it. This makes single sign-on possible (the AP
    // might automatically grant a token for a domain if a token for an affiliated domain has already been granted)
    CPAIdentity *identity = [self identity];
    if (identity) {
        [self requestTokenForDomain:domain withType:type identity:identity credentialsPresentationBlock:credentialsPresentationBlock completionBlock:completionBlock];
    }
    else {
        NSString *clientName = [NSBundle mainBundle].infoDictionary[@"CFBundleName"];
        NSAssert(clientName, @"A client name is required");
        
        NSString *softwareIdentifier = [NSBundle mainBundle].bundleIdentifier;
        NSAssert(softwareIdentifier, @"A software identifier is required");
        
        NSString *softwareVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
        NSAssert(softwareVersion, @"A software version is required");
        
        [CPAStatelessRequest registerClientWithAuthorizationProviderURL:self.authorizationProviderURL clientName:clientName softwareIdentifier:softwareIdentifier softwareVersion:softwareVersion completionBlock:^(NSString *clientIdentifier, NSString *clientSecret, NSError *error) {
            if (error) {
                completionBlock ? completionBlock(nil, nil, nil, 0, error) : nil;
                return;
            }
            
            CPAIdentity *identity = [[CPAIdentity alloc] initWithIdentifier:clientIdentifier secret:clientSecret];
            [self setIdentity:identity];
            
            [self requestTokenForDomain:domain withType:type identity:identity credentialsPresentationBlock:credentialsPresentationBlock completionBlock:completionBlock];
        }];
    }
}

/**
 * Request a client / user token for the specified domain on behalf of the provided identity
 */
- (void)requestTokenForDomain:(NSString *)domain
                     withType:(CPATokenType)type
                     identity:(CPAIdentity *)identity
 credentialsPresentationBlock:(CPACredentialsPresentationBlock)credentialsPresentationBlock
              completionBlock:(CPATokenInformationCompletionBlock)completionBlock
{
    // There is no special code required to refresh a token vs. obtaining the first token. For client tokens, just ask for a new token. For user tokens,
    // get a user code and request a token. If a user token was already obtained and can be refreshed, no verification will be needed and the token
    // will be delivered immediately
    if (type == CPATokenTypeUser) {
        [self requestCodeAndUserTokenForDomain:domain withIdentity:identity credentialsPresentationBlock:credentialsPresentationBlock completionBlock:completionBlock];
    }
    else {
        [CPAStatelessRequest requestClientTokenWithAuthorizationProviderURL:self.authorizationProviderURL clientIdentifier:identity.identifier clientSecret:identity.secret domain:domain completionBlock:^(NSString *accessToken, NSString *tokenType, NSString *domainName, NSInteger expiresInSeconds, NSError *error) {
            completionBlock(nil, accessToken, domainName, expiresInSeconds, error);
        }];
    }
}

- (void)requestCodeAndUserTokenForDomain:(NSString *)domain
                            withIdentity:(CPAIdentity *)identity
            credentialsPresentationBlock:(CPACredentialsPresentationBlock)credentialsPresentationBlock
                         completionBlock:(CPATokenInformationCompletionBlock)completionBlock
{
    [CPAStatelessRequest requestCodeWithAuthorizationProviderURL:self.authorizationProviderURL clientIdentifier:identity.identifier clientSecret:identity.secret domain:domain completionBlock:^(NSString *deviceCode, NSString *userCode, NSURL *verificationURL, NSInteger pollingInterval, NSInteger expiresInSeconds, NSError *error) {
        if (error) {
            // The client has been revoked and no user code can be retrieved for it anymore. Start again from scratch, registering a new client
            if ([error.domain isEqualToString:CPAErrorDomain] && error.code == CPAErrorInvalidClient) {
                [self discardIdentity];
                [self registerAndRequestTokenForDomain:domain withType:CPATokenTypeUser credentialsPresentationBlock:credentialsPresentationBlock completionBlock:completionBlock];
                return;
            }
            
            completionBlock ? completionBlock(nil, nil, nil, 0, error) : nil;
            return;
        }
        
        // Open verification URL built-in browser
        if (verificationURL) {
            CPAAuthorizationViewController *authorizationViewController = [[CPAAuthorizationViewController alloc] initWithVerificationURL:verificationURL userCode:userCode];
            credentialsPresentationBlock ? credentialsPresentationBlock(authorizationViewController, YES) : nil;
            
            __weak CPAAuthorizationViewController *weakAuthorizationViewController = authorizationViewController;
            authorizationViewController.completionBlock = ^(NSError *error) {
                credentialsPresentationBlock ? credentialsPresentationBlock(weakAuthorizationViewController, NO) : nil;
                
                if (error) {
                    completionBlock ? completionBlock(nil, nil, nil, 0, error) : nil;
                    return;
                }
                
                [CPAStatelessRequest requestUserTokenWithAuthorizationProviderURL:self.authorizationProviderURL deviceCode:deviceCode clientIdentifier:identity.identifier clientSecret:identity.secret domain:domain completionBlock:^(NSString *userName, NSString *accessToken, NSString *tokenType, NSString *domainName, NSInteger expiresInSeconds, NSError *error) {
                    completionBlock(userName, accessToken, domainName, expiresInSeconds, error);
                }];
            };
        }
        // If no verification URL is received, this means that a refresh can be made without having to enter credentials
        // and validate the application again. Proceed with token retrieval
        else {
            [CPAStatelessRequest requestUserTokenWithAuthorizationProviderURL:self.authorizationProviderURL deviceCode:deviceCode clientIdentifier:identity.identifier clientSecret:identity.secret domain:domain completionBlock:^(NSString *userName, NSString *accessToken, NSString *tokenType, NSString *domainName, NSInteger expiresInSeconds, NSError *error) {
                completionBlock(userName, accessToken, domainName, expiresInSeconds, error);
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

- (NSString *)keyChainIdentifier
{
    return self.authorizationProviderURL.absoluteString;
}

- (CPAIdentity *)identity
{
    NSData *identityData = [self.keyChainStore dataForKey:self.keyChainIdentifier];
    return identityData ? [NSKeyedUnarchiver unarchiveObjectWithData:identityData] : nil;
}

- (void)setIdentity:(CPAIdentity *)identity
{
    NSData *identityData = [NSKeyedArchiver archivedDataWithRootObject:identity];
    [self.keyChainStore setData:identityData forKey:self.keyChainIdentifier];
}

- (void)discardIdentity
{
    [self.keyChainStore removeItemForKey:self.keyChainIdentifier];
}

- (NSString *)keyChainKeyForDomain:(NSString *)domain
{
    NSParameterAssert(domain);
    
    // FIXME: If we want to support multiple users per application, the key should also contain a reference
    //        to a reliable user identifier. Currently only the user display name can be retrieved (user_name),
    //        which is sadly not reliable enough since it might change
    return [NSString stringWithFormat:@"%@_%@", self.keyChainIdentifier, domain];
}

- (void)setToken:(CPAToken *)token forDomain:(NSString *)domain
{
    NSParameterAssert(domain);
    
    NSData *tokenData = [NSKeyedArchiver archivedDataWithRootObject:token];
    NSString *key = [self keyChainKeyForDomain:domain];
    [self.keyChainStore setData:tokenData forKey:key];
}

#pragma mark Actions

- (void)closeCredentials:(id)sender
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
