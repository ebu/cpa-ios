//
//  EBUUICKeyChainStore.h
//  EBUUICKeyChainStore
//
//  Created by Kishikawa Katsumi on 11/11/20.
//  Copyright (c) 2011 Kishikawa Katsumi. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const EBUUICKeyChainStoreErrorDomain;

typedef NS_ENUM(NSInteger, EBUUICKeyChainStoreErrorCode) {
    EBUUICKeyChainStoreErrorInvalidArguments = 1,
};

typedef NS_ENUM(NSInteger, EBUUICKeyChainStoreItemClass) {
    EBUUICKeyChainStoreItemClassGenericPassword = 1,
    EBUUICKeyChainStoreItemClassInternetPassword,
};

typedef NS_ENUM(NSInteger, EBUUICKeyChainStoreProtocolType) {
    EBUUICKeyChainStoreProtocolTypeFTP = 1,
    EBUUICKeyChainStoreProtocolTypeFTPAccount,
    EBUUICKeyChainStoreProtocolTypeHTTP,
    EBUUICKeyChainStoreProtocolTypeIRC,
    EBUUICKeyChainStoreProtocolTypeNNTP,
    EBUUICKeyChainStoreProtocolTypePOP3,
    EBUUICKeyChainStoreProtocolTypeSMTP,
    EBUUICKeyChainStoreProtocolTypeSOCKS,
    EBUUICKeyChainStoreProtocolTypeIMAP,
    EBUUICKeyChainStoreProtocolTypeLDAP,
    EBUUICKeyChainStoreProtocolTypeAppleTalk,
    EBUUICKeyChainStoreProtocolTypeAFP,
    EBUUICKeyChainStoreProtocolTypeTelnet,
    EBUUICKeyChainStoreProtocolTypeSSH,
    EBUUICKeyChainStoreProtocolTypeFTPS,
    EBUUICKeyChainStoreProtocolTypeHTTPS,
    EBUUICKeyChainStoreProtocolTypeHTTPProxy,
    EBUUICKeyChainStoreProtocolTypeHTTPSProxy,
    EBUUICKeyChainStoreProtocolTypeFTPProxy,
    EBUUICKeyChainStoreProtocolTypeSMB,
    EBUUICKeyChainStoreProtocolTypeRTSP,
    EBUUICKeyChainStoreProtocolTypeRTSPProxy,
    EBUUICKeyChainStoreProtocolTypeDAAP,
    EBUUICKeyChainStoreProtocolTypeEPPC,
    EBUUICKeyChainStoreProtocolTypeNNTPS,
    EBUUICKeyChainStoreProtocolTypeLDAPS,
    EBUUICKeyChainStoreProtocolTypeTelnetS,
    EBUUICKeyChainStoreProtocolTypeIRCS,
    EBUUICKeyChainStoreProtocolTypePOP3S,
};

typedef NS_ENUM(NSInteger, EBUUICKeyChainStoreAuthenticationType) {
    EBUUICKeyChainStoreAuthenticationTypeNTLM = 1,
    EBUUICKeyChainStoreAuthenticationTypeMSN,
    EBUUICKeyChainStoreAuthenticationTypeDPA,
    EBUUICKeyChainStoreAuthenticationTypeRPA,
    EBUUICKeyChainStoreAuthenticationTypeHTTPBasic,
    EBUUICKeyChainStoreAuthenticationTypeHTTPDigest,
    EBUUICKeyChainStoreAuthenticationTypeHTMLForm,
    EBUUICKeyChainStoreAuthenticationTypeDefault,
};

typedef NS_ENUM(NSInteger, EBUUICKeyChainStoreAccessibility) {
    EBUUICKeyChainStoreAccessibilityWhenUnlocked = 1,
    EBUUICKeyChainStoreAccessibilityAfterFirstUnlock,
    EBUUICKeyChainStoreAccessibilityAlways,
    EBUUICKeyChainStoreAccessibilityWhenPasscodeSetThisDeviceOnly
    __OSX_AVAILABLE_STARTING(__MAC_10_10, __IPHONE_8_0),
    EBUUICKeyChainStoreAccessibilityWhenUnlockedThisDeviceOnly,
    EBUUICKeyChainStoreAccessibilityAfterFirstUnlockThisDeviceOnly,
    EBUUICKeyChainStoreAccessibilityAlwaysThisDeviceOnly,
}
__OSX_AVAILABLE_STARTING(__MAC_10_9, __IPHONE_4_0);

typedef NS_ENUM(NSInteger, EBUUICKeyChainStoreAuthenticationPolicy) {
    EBUUICKeyChainStoreAuthenticationPolicyUserPresence = kSecAccessControlUserPresence,
};

@interface EBUUICKeyChainStore : NSObject

@property (nonatomic, readonly) EBUUICKeyChainStoreItemClass itemClass;

@property (nonatomic, readonly) NSString *service;
@property (nonatomic, readonly) NSString *accessGroup;

@property (nonatomic, readonly) NSURL *server;
@property (nonatomic, readonly) EBUUICKeyChainStoreProtocolType protocolType;
@property (nonatomic, readonly) EBUUICKeyChainStoreAuthenticationType authenticationType;

@property (nonatomic) EBUUICKeyChainStoreAccessibility accessibility;
@property (nonatomic, readonly) EBUUICKeyChainStoreAuthenticationPolicy authenticationPolicy
__OSX_AVAILABLE_STARTING(__MAC_10_10, __IPHONE_8_0);

@property (nonatomic) BOOL synchronizable;

@property (nonatomic) NSString *authenticationPrompt
__OSX_AVAILABLE_STARTING(__MAC_NA, __IPHONE_8_0);

@property (nonatomic, readonly) NSArray *allKeys;
@property (nonatomic, readonly) NSArray *allItems;

+ (NSString *)defaultService;
+ (void)setDefaultService:(NSString *)defaultService;

+ (EBUUICKeyChainStore *)keyChainStore;
+ (EBUUICKeyChainStore *)keyChainStoreWithService:(NSString *)service;
+ (EBUUICKeyChainStore *)keyChainStoreWithService:(NSString *)service accessGroup:(NSString *)accessGroup;

+ (EBUUICKeyChainStore *)keyChainStoreWithServer:(NSURL *)server protocolType:(EBUUICKeyChainStoreProtocolType)protocolType;
+ (EBUUICKeyChainStore *)keyChainStoreWithServer:(NSURL *)server protocolType:(EBUUICKeyChainStoreProtocolType)protocolType authenticationType:(EBUUICKeyChainStoreAuthenticationType)authenticationType;

- (instancetype)init;
- (instancetype)initWithService:(NSString *)service;
- (instancetype)initWithService:(NSString *)service accessGroup:(NSString *)accessGroup;

- (instancetype)initWithServer:(NSURL *)server protocolType:(EBUUICKeyChainStoreProtocolType)protocolType;
- (instancetype)initWithServer:(NSURL *)server protocolType:(EBUUICKeyChainStoreProtocolType)protocolType authenticationType:(EBUUICKeyChainStoreAuthenticationType)authenticationType;

+ (NSString *)stringForKey:(NSString *)key;
+ (NSString *)stringForKey:(NSString *)key service:(NSString *)service;
+ (NSString *)stringForKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup;
+ (BOOL)setString:(NSString *)value forKey:(NSString *)key;
+ (BOOL)setString:(NSString *)value forKey:(NSString *)key service:(NSString *)service;
+ (BOOL)setString:(NSString *)value forKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup;

+ (NSData *)dataForKey:(NSString *)key;
+ (NSData *)dataForKey:(NSString *)key service:(NSString *)service;
+ (NSData *)dataForKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup;
+ (BOOL)setData:(NSData *)data forKey:(NSString *)key;
+ (BOOL)setData:(NSData *)data forKey:(NSString *)key service:(NSString *)service;
+ (BOOL)setData:(NSData *)data forKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup;

- (BOOL)contains:(NSString *)key;

- (BOOL)setString:(NSString *)string forKey:(NSString *)key;
- (BOOL)setString:(NSString *)string forKey:(NSString *)key label:(NSString *)label comment:(NSString *)comment;
- (NSString *)stringForKey:(NSString *)key;

- (BOOL)setData:(NSData *)data forKey:(NSString *)key;
- (BOOL)setData:(NSData *)data forKey:(NSString *)key label:(NSString *)label comment:(NSString *)comment;
- (NSData *)dataForKey:(NSString *)key;

+ (BOOL)removeItemForKey:(NSString *)key;
+ (BOOL)removeItemForKey:(NSString *)key service:(NSString *)service;
+ (BOOL)removeItemForKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup;

+ (BOOL)removeAllItems;
+ (BOOL)removeAllItemsForService:(NSString *)service;
+ (BOOL)removeAllItemsForService:(NSString *)service accessGroup:(NSString *)accessGroup;

- (BOOL)removeItemForKey:(NSString *)key;

- (BOOL)removeAllItems;

- (NSString *)objectForKeyedSubscript:(NSString <NSCopying> *)key;
- (void)setObject:(NSString *)obj forKeyedSubscript:(NSString <NSCopying> *)key;

+ (NSArray *)allKeysWithItemClass:(EBUUICKeyChainStoreItemClass)itemClass;
- (NSArray *)allKeys;

+ (NSArray *)allItemsWithItemClass:(EBUUICKeyChainStoreItemClass)itemClass;
- (NSArray *)allItems;

- (void)setAccessibility:(EBUUICKeyChainStoreAccessibility)accessibility authenticationPolicy:(EBUUICKeyChainStoreAuthenticationPolicy)authenticationPolicy
__OSX_AVAILABLE_STARTING(__MAC_10_10, __IPHONE_8_0);

#if TARGET_OS_IPHONE
- (void)sharedPasswordWithCompletion:(void (^)(NSString *account, NSString *password, NSError *error))completion;
- (void)sharedPasswordForAccount:(NSString *)account completion:(void (^)(NSString *password, NSError *error))completion;

- (void)setSharedPassword:(NSString *)password forAccount:(NSString *)account completion:(void (^)(NSError *error))completion;
- (void)removeSharedPasswordForAccount:(NSString *)account completion:(void (^)(NSError *error))completion;

+ (void)requestSharedWebCredentialWithCompletion:(void (^)(NSArray *credentials, NSError *error))completion;
+ (void)requestSharedWebCredentialForDomain:(NSString *)domain account:(NSString *)account completion:(void (^)(NSArray *credentials, NSError *error))completion;

+ (NSString *)generatePassword;
#endif

@end

@interface EBUUICKeyChainStore (ErrorHandling)

+ (NSString *)stringForKey:(NSString *)key error:(NSError * __autoreleasing *)error;
+ (NSString *)stringForKey:(NSString *)key service:(NSString *)service error:(NSError * __autoreleasing *)error;
+ (NSString *)stringForKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup error:(NSError * __autoreleasing *)error;

+ (BOOL)setString:(NSString *)value forKey:(NSString *)key error:(NSError * __autoreleasing *)error;
+ (BOOL)setString:(NSString *)value forKey:(NSString *)key service:(NSString *)service error:(NSError * __autoreleasing *)error;
+ (BOOL)setString:(NSString *)value forKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup error:(NSError * __autoreleasing *)error;

+ (NSData *)dataForKey:(NSString *)key error:(NSError * __autoreleasing *)error;
+ (NSData *)dataForKey:(NSString *)key service:(NSString *)service error:(NSError * __autoreleasing *)error;
+ (NSData *)dataForKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup error:(NSError * __autoreleasing *)error;

+ (BOOL)setData:(NSData *)data forKey:(NSString *)key error:(NSError * __autoreleasing *)error;
+ (BOOL)setData:(NSData *)data forKey:(NSString *)key service:(NSString *)service error:(NSError * __autoreleasing *)error;
+ (BOOL)setData:(NSData *)data forKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup error:(NSError * __autoreleasing *)error;

- (BOOL)setString:(NSString *)string forKey:(NSString *)key error:(NSError * __autoreleasing *)error;
- (BOOL)setString:(NSString *)string forKey:(NSString *)key label:(NSString *)label comment:(NSString *)comment error:(NSError * __autoreleasing *)error;

- (BOOL)setData:(NSData *)data forKey:(NSString *)key error:(NSError * __autoreleasing *)error;
- (BOOL)setData:(NSData *)data forKey:(NSString *)key label:(NSString *)label comment:(NSString *)comment error:(NSError * __autoreleasing *)error;

- (NSString *)stringForKey:(NSString *)key error:(NSError * __autoreleasing *)error;
- (NSData *)dataForKey:(NSString *)key error:(NSError * __autoreleasing *)error;

+ (BOOL)removeItemForKey:(NSString *)key error:(NSError * __autoreleasing *)error;
+ (BOOL)removeItemForKey:(NSString *)key service:(NSString *)service error:(NSError * __autoreleasing *)error;
+ (BOOL)removeItemForKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup error:(NSError * __autoreleasing *)error;

+ (BOOL)removeAllItemsWithError:(NSError * __autoreleasing *)error;
+ (BOOL)removeAllItemsForService:(NSString *)service error:(NSError * __autoreleasing *)error;
+ (BOOL)removeAllItemsForService:(NSString *)service accessGroup:(NSString *)accessGroup error:(NSError * __autoreleasing *)error;

- (BOOL)removeItemForKey:(NSString *)key error:(NSError * __autoreleasing *)error;
- (BOOL)removeAllItemsWithError:(NSError * __autoreleasing *)error;

@end

@interface EBUUICKeyChainStore (ForwardCompatibility)

+ (BOOL)setString:(NSString *)value forKey:(NSString *)key genericAttribute:(id)genericAttribute;
+ (BOOL)setString:(NSString *)value forKey:(NSString *)key genericAttribute:(id)genericAttribute error:(NSError * __autoreleasing *)error;

+ (BOOL)setString:(NSString *)value forKey:(NSString *)key service:(NSString *)service genericAttribute:(id)genericAttribute;
+ (BOOL)setString:(NSString *)value forKey:(NSString *)key service:(NSString *)service genericAttribute:(id)genericAttribute error:(NSError * __autoreleasing *)error;

+ (BOOL)setString:(NSString *)value forKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup genericAttribute:(id)genericAttribute;
+ (BOOL)setString:(NSString *)value forKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup genericAttribute:(id)genericAttribute error:(NSError * __autoreleasing *)error;

+ (BOOL)setData:(NSData *)data forKey:(NSString *)key genericAttribute:(id)genericAttribute;
+ (BOOL)setData:(NSData *)data forKey:(NSString *)key genericAttribute:(id)genericAttribute error:(NSError * __autoreleasing *)error;

+ (BOOL)setData:(NSData *)data forKey:(NSString *)key service:(NSString *)service genericAttribute:(id)genericAttribute;
+ (BOOL)setData:(NSData *)data forKey:(NSString *)key service:(NSString *)service genericAttribute:(id)genericAttribute error:(NSError * __autoreleasing *)error;

+ (BOOL)setData:(NSData *)data forKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup genericAttribute:(id)genericAttribute;
+ (BOOL)setData:(NSData *)data forKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup genericAttribute:(id)genericAttribute error:(NSError * __autoreleasing *)error;

- (BOOL)setString:(NSString *)string forKey:(NSString *)key genericAttribute:(id)genericAttribute;
- (BOOL)setString:(NSString *)string forKey:(NSString *)key genericAttribute:(id)genericAttribute error:(NSError * __autoreleasing *)error;

- (BOOL)setData:(NSData *)data forKey:(NSString *)key genericAttribute:(id)genericAttribute;
- (BOOL)setData:(NSData *)data forKey:(NSString *)key genericAttribute:(id)genericAttribute error:(NSError * __autoreleasing *)error;

@end

@interface EBUUICKeyChainStore (Deprecation)

- (void)synchronize __attribute__((deprecated("calling this method is no longer required")));
- (BOOL)synchronizeWithError:(NSError *__autoreleasing *)error __attribute__((deprecated("calling this method is no longer required")));

@end
