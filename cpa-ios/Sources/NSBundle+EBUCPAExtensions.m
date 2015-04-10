//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "NSBundle+EBUCPAExtensions.h"

#import "EBUToken.h"

@implementation NSBundle (EBUCPAExtensions)

+ (NSBundle *)ebucpa_principalBundle
{
    static NSBundle *s_principalBundle;
    static dispatch_once_t s_onceToken;
    dispatch_once(&s_onceToken, ^{
        s_principalBundle = [NSBundle bundleForClass:[EBUToken class]];
    });
    return s_principalBundle;
}

+ (NSBundle *)ebucpa_resourceBundle
{
    NSString *resourceBundlePath = [[NSBundle mainBundle].bundlePath stringByAppendingPathComponent:@"cpa-ios-resources.bundle"];
    NSBundle *resourceBundle = [NSBundle bundleWithPath:resourceBundlePath];
    if (! resourceBundle) {
        resourceBundle = [self ebucpa_principalBundle];
        NSAssert(resourceBundle, @"The EBU CPA resource bundle must be available");
    }
    return resourceBundle;
}

@end
