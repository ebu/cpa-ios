//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "AppDelegate.h"

#import "CPAProvider.h"

@implementation AppDelegate

#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSURL *providerURL = [NSURL URLWithString:@"https://cpa.rts.ch"];
    CPAProvider *provider = [[CPAProvider alloc] initWithAuthorizationProviderURL:providerURL];
    [CPAProvider setDefaultProvider:provider];
    
    return YES;
}

@end
