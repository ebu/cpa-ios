//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CPAIdentity : NSObject <NSCoding>

/**
 * The identifier attributed by the authorization provider
 */
@property (nonatomic, readonly, copy) NSString *identifier;

/**
 * The client secret returned by the authorization provider
 */
@property (nonatomic, readonly, copy) NSString *secret;

@end

@interface CPAIdentity (UnavailableMethods)

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
