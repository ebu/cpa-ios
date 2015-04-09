//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "AppDelegate.h"

#import "EBUCrossPlatformAuthenticationProvider.h"

@implementation AppDelegate

#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSURL *providerURL = [NSURL URLWithString:@"https://cpa.rts.ch"];
    EBUCrossPlatformAuthenticationProvider *authenticationProvider = [[EBUCrossPlatformAuthenticationProvider alloc] initWithAuthorizationProviderURL:providerURL];
    [EBUCrossPlatformAuthenticationProvider setDefaultAuthenticationProvider:authenticationProvider];
    
    return YES;
}

@end
