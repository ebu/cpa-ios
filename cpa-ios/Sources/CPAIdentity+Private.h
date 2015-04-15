//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "CPAIdentity.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Private interface for implementation purposes
 */
@interface CPAIdentity (Private)

/**
 * Create a token with the specified parameters (all mandatory)
 */
- (instancetype)initWithIdentifier:(NSString *)identifier
                            secret:(NSString *)secret;

@end

NS_ASSUME_NONNULL_END
