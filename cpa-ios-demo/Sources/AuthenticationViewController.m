//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "AuthenticationViewController.h"

#import "CPAProvider.h"

static NSString * const kDomain = @"cpa.rts.ch";

@interface AuthenticationViewController ()

@property (nonatomic, weak) IBOutlet UILabel *tokenLabel;
@property (nonatomic, weak) IBOutlet UISwitch *userTokenSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *forceRenewalSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *customTransitionSwitch;

@end

@implementation AuthenticationViewController

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self reloadData];
}

#pragma mark UI

- (void)reloadData
{
    CPAToken *token = [[CPAProvider defaultProvider] tokenForDomain:kDomain];
    if (token) {
        self.tokenLabel.text = [NSString stringWithFormat:@"%@\n(%@)", token.value, (token.type == CPATokenTypeClient) ? NSLocalizedString(@"Client", nil) : NSLocalizedString(@"User", nil)];
    }
    else {
        self.tokenLabel.text = NSLocalizedString(@"None", nil);
    }
}

#pragma mark Token retrieval

- (IBAction)retrieveToken:(id)sender
{
    CPAToken *existingToken = [[CPAProvider defaultProvider] tokenForDomain:kDomain];
    if (existingToken && ! self.forceRenewalSwitch.on) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Information", nil)
                                                            message:NSLocalizedString(@"A token is already available", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    CPACredentialsPresentationBlock credentialsPresentationBlock = nil;
    if (self.customTransitionSwitch.on) {
        credentialsPresentationBlock = ^(UIViewController *viewController, BOOL isPresenting) {
            if (isPresenting) {
                [self.navigationController pushViewController:viewController animated:YES];
            }
            else {
                [self.navigationController popViewControllerAnimated:YES];
            }
        };
    }
    
    CPATokenType type = self.userTokenSwitch.on ? CPATokenTypeUser : CPATokenTypeClient;
    [[CPAProvider defaultProvider] requestTokenForDomain:kDomain withType:type credentialsPresentationBlock:credentialsPresentationBlock completionBlock:^(CPAToken *token, NSError *error) {
        if (error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                                message:[error localizedDescription]
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                                      otherButtonTitles:nil];
            [alertView show];
            return;
        }
        
        [self reloadData];
    }];
}

@end
