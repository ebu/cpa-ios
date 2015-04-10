//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import <Foundation/Foundation.h>

#define EBUCPALocalizedString(key, comment) \
    [[NSBundle ebucpa_resourceBundle] localizedStringForKey:(key) value:@"" table:nil]

@interface NSBundle (EBUCPAExtensions)

/**
 * The resource bundle associated with the library
 */
+ (NSBundle *)ebucpa_resourceBundle;

@end
