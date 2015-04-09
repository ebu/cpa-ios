//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "AuthenticationViewController.h"

#import "EBUCrossPlatformAuthenticationProvider.h"

@interface AuthenticationViewController ()

@property (nonatomic, weak) IBOutlet UILabel *clientTokenLabel;
@property (nonatomic, weak) IBOutlet UILabel *userTokenLabel;

@end

@implementation AuthenticationViewController

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.clientTokenLabel.text = nil;
    self.userTokenLabel.text = nil;
}

#pragma mark Actions

- (IBAction)retrieveClientToken:(id)sender
{
    [[EBUCrossPlatformAuthenticationProvider defaultAuthenticationProvider] requestTokenForDomain:@"cpa.rts.ch" authenticated:NO withCompletionBlock:^(EBUToken *token, NSError *error) {
        if (error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                                message:[error localizedDescription]
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                                      otherButtonTitles:nil];
            [alertView show];
        }
        
        self.clientTokenLabel.text = token.value;
    }];
}

- (IBAction)retrieveUserToken:(id)sender
{
    [[EBUCrossPlatformAuthenticationProvider defaultAuthenticationProvider] requestTokenForDomain:@"cpa.rts.ch" authenticated:YES withCompletionBlock:^(EBUToken *token, NSError *error) {
        if (error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                                message:[error localizedDescription]
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                                      otherButtonTitles:nil];
            [alertView show];
        }
        
        self.userTokenLabel.text = token.value;
    }];
}

@end
