//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "CPAToken.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Private interface for implementation purposes
 */
@interface CPAToken (Private)

/**
 * Create a token with the specified value and domain, associated with the specified client (all parameters are
 * mandatory)
 */
- (instancetype)initWithValue:(NSString *)value
             clientIdentifier:(NSString *)clientIdentifier
                 clientSecret:(NSString *)clientSecret
                       domain:(NSString *)domain;

/**
 * The friendly domain name (defaults to nil)
 */
@property (nonatomic, copy, nullable) NSString *domainName;

/**
 * Token type. Defaults to CPATokenTypeClient
 */
@property (nonatomic) CPATokenType type;

/**
 * Lifetime of the token in seconds
 */
@property (nonatomic) NSInteger lifetimeInSeconds;

@end

NS_ASSUME_NONNULL_END
