//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "CPAIdentity.h"
#import "CPANullability.h"

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
