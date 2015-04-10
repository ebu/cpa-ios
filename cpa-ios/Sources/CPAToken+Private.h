//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "CPAToken.h"

/**
 * Private interface for implementation purposes
 */
@interface CPAToken (Private)

/**
 * Create a token with the specified value and domain (both mandatory)
 */
- (instancetype)initWithValue:(NSString *)value domain:(NSString *)domain;

/**
 * The friendly domain name (defaults to nil)
 */
@property (nonatomic, copy) NSString *domainName;

/**
 * Token type. Defaults to CPATokenTypeClient
 */
@property (nonatomic) CPATokenType type;

/**
 * Lifetime of the token in seconds
 */
@property (nonatomic) NSInteger lifetimeInSeconds;

@end
