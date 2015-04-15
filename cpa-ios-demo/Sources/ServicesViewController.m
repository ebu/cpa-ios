//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "ServicesViewController.h"

#import "ServiceViewController.h"

@implementation ServicesViewController

#pragma mark Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSAssert([segue.destinationViewController isKindOfClass:[ServiceViewController class]], @"Unexpected segue destination");
    ServiceViewController *serviceViewController = segue.destinationViewController;
    serviceViewController.serviceIdentifier = segue.identifier;
}

@end
