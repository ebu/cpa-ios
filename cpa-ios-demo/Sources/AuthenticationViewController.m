//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "AuthenticationViewController.h"

#import "EBUCrossPlatformAuthenticationProvider.h"

static NSString * const kDomain = @"cpa.rts.ch";

@interface AuthenticationViewController ()

@property (nonatomic, weak) IBOutlet UILabel *tokenLabel;
@property (nonatomic, weak) IBOutlet UISwitch *userTokenSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *forceRenewalSwitch;

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
    EBUToken *token = [[EBUCrossPlatformAuthenticationProvider defaultAuthenticationProvider] tokenForDomain:kDomain];
    if (token) {
        self.tokenLabel.text = [NSString stringWithFormat:@"%@\n(%@)", token.value, (token.type == EBUTokenTypeClient) ? NSLocalizedString(@"Client", nil) : NSLocalizedString(@"User", nil)];
    }
    else {
        self.tokenLabel.text = NSLocalizedString(@"None", nil);
    }
}

#pragma mark Actions

- (IBAction)retrieveToken:(id)sender
{
    EBUToken *existingToken = [[EBUCrossPlatformAuthenticationProvider defaultAuthenticationProvider] tokenForDomain:kDomain];
    if (existingToken && ! self.forceRenewalSwitch.on) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Information", nil)
                                                            message:NSLocalizedString(@"A token is already available", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"Dismiss", nil)
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    EBUTokenType type = self.userTokenSwitch.on ? EBUTokenTypeUser : EBUTokenTypeClient;
    [[EBUCrossPlatformAuthenticationProvider defaultAuthenticationProvider] requestTokenForDomain:kDomain withType:type completionBlock:^(EBUToken *token, NSError *error) {
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
