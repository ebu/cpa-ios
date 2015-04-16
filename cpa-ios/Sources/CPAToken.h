//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Token type
 */
typedef NS_ENUM(NSInteger, CPATokenType) {
    CPATokenTypeClient,                 // Client token (unauthenticated)
    CPATokenTypeUser                    // User token (authenticated)
};

/**
 * Service token
 */
@interface CPAToken : NSObject <NSCoding>

/**
 * The token string
 */
@property (nonatomic, readonly, copy) NSString *value;

/**
 * The domain to which the token is associated
 */
@property (nonatomic, readonly, copy) NSString *domain;

/**
 * The friendly domain name
 */
@property (nonatomic, readonly, copy, nullable) NSString *domainName;

/**
 * The friendly name of the user account associated with the token, nil for a client token
 */
@property (nonatomic, readonly, copy, nullable) NSString *userName;

/**
 * The token type
 */
@property (nonatomic, readonly) CPATokenType type;

/**
 * The date at which the token is supposed to expire
 */
@property (nonatomic, readonly) NSDate *expirationDate;

@end

@interface CPAToken (UnavailableMethods)

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
