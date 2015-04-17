//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "NSBundle+Tests.h"

@interface DummyClass : NSObject
@end

@implementation DummyClass
@end

@implementation NSBundle (Tests)

+ (NSBundle *)testBundle
{
    static NSBundle *s_testBundle;
    static dispatch_once_t s_onceToken;
    dispatch_once(&s_onceToken, ^{
        s_testBundle = [NSBundle bundleForClass:[DummyClass class]];
    });
    return s_testBundle;
}

@end
