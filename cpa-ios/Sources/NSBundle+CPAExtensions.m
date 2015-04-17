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
    // Look for a resource bundle in the main bundle first (e.g. CocoaPods without use_frameworks!)
    NSString *resourceBundlePath = [[[NSBundle mainBundle].bundlePath stringByAppendingPathComponent:CPAResourcesBundleName] stringByAppendingPathExtension:@"bundle"];
    NSBundle *resourceBundle = [NSBundle bundleWithPath:resourceBundlePath];
    if (! resourceBundle) {
        // Look for a resource bundle in the associated .framework, if any (e.g. CocoaPods with use_frameworks!)
        NSBundle *principalBundle = [self cpa_principalBundle];
        NSString *embeddedFrameworkResourceBundlePath = [[principalBundle.bundlePath stringByAppendingPathComponent:CPAResourcesBundleName] stringByAppendingPathExtension:@"bundle"];
        resourceBundle = [NSBundle bundleWithPath:embeddedFrameworkResourceBundlePath];
        if (! resourceBundle) {
            // Look for resources in the main .framework, standard way of bundling resources (e.g. Carthage)
            resourceBundle = [self cpa_principalBundle];
        }
    }
    return resourceBundle;
}

@end
