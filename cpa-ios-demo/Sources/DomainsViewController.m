//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "DomainsViewController.h"

#import "DomainViewController.h"

@implementation DomainsViewController

#pragma mark Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSAssert([segue.destinationViewController isKindOfClass:[DomainViewController class]], @"Unexpected segue destination");
    DomainViewController *domainViewController = segue.destinationViewController;
    domainViewController.domain = segue.identifier;
}

@end
