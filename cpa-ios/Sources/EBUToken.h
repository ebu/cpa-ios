//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import <Foundation/Foundation.h>

/**
 * A service token
 */
@interface EBUToken : NSObject

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
@property (nonatomic, readonly, copy) NSString *domainName;

/**
 * Return YES if the token is authenticated (user token), no otherwise (client token)
 */
@property (nonatomic, readonly, getter=isAuthenticated) BOOL authenticated;

@end

@interface EBUToken (UnavailableMethods)

- (instancetype)init NS_UNAVAILABLE;

@end
