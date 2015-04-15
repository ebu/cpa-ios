//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "NSBundle+CPAExtensions.h"

#import "CPAToken.h"

NSString * const CPAResourcesBundleName = @"CrossPlatformAuthentication-resources";

@implementation NSBundle (CPAExtensions)

+ (NSBundle *)cpa_principalBundle
{
    static NSBundle *s_principalBundle;
    static dispatch_once_t s_onceToken;
    dispatch_once(&s_onceToken, ^{
        s_principalBundle = [NSBundle bundleForClass:[CPAToken class]];
    });
    return s_principalBundle;
}

+ (NSBundle *)cpa_resourceBundle
{
    NSString *resourceBundlePath = [[[NSBundle mainBundle].bundlePath stringByAppendingPathComponent:CPAResourcesBundleName] stringByAppendingPathExtension:@"bundle"];
    NSBundle *resourceBundle = [NSBundle bundleWithPath:resourceBundlePath];
    if (! resourceBundle) {
        resourceBundle = [self cpa_principalBundle];
        NSAssert(resourceBundle, @"The EBU CPA resource bundle must be available");
    }
    return resourceBundle;
}

@end
