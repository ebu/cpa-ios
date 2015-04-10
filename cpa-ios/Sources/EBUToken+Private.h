//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "EBUToken.h"

/**
 * Private interface for implementation purposes
 */
@interface EBUToken (Private)

/**
 * Create a token with the specified value and domain (both mandatory)
 */
- (instancetype)initWithValue:(NSString *)value domain:(NSString *)domain;

/**
 * The friendly domain name (defaults to nil)
 */
@property (nonatomic, copy) NSString *domainName;

/**
 * Set to YES if the token is authenticated (user token), no otherwise (client token). Default is NO
 */
@property (nonatomic, getter=isAuthenticated) BOOL authenticated;

@end
