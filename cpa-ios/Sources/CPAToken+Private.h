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
 * Create a token with the specified parameters (all mandatory)
 */
- (instancetype)initWithValue:(NSString *)value
                       domain:(NSString *)domain
                   domainName:(NSString *)domainName
                     userName:(NSString *)userName
               expirationDate:(NSDate *)expirationDate;

@end

NS_ASSUME_NONNULL_END
