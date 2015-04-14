//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import <Foundation/Foundation.h>

#define CPALocalizedString(key, comment) \
    [[NSBundle cpa_resourceBundle] localizedStringForKey:(key) value:@"" table:nil]

NS_ASSUME_NONNULL_BEGIN
@interface NSBundle (CPAExtensions)

/**
 * The resource bundle associated with the library
 */
+ (NSBundle *)cpa_resourceBundle;

@end
NS_ASSUME_NONNULL_END
