//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "DomainViewController.h"

#import "CPAProvider.h"

NSString *NameForDomain(NSString *domain)
{
    static NSDictionary *s_names = nil;
    static dispatch_once_t s_onceToken;
    dispatch_once(&s_onceToken, ^{
        s_names = @{ @"playlist.rts.ch" : NSLocalizedString(@"RTS Playlist", nil),
                     @"hbbtv.rts.ch" : NSLocalizedString(@"RTS HbbTV", nil),
                     @"unsupported.ch" : NSLocalizedString(@"Unsupported domain", nil) };
    });
    return s_names[domain] ?: NSLocalizedString(@"Unknown domain", nil);
}

@interface DomainViewController ()

@property (nonatomic, weak) IBOutlet UILabel *tokenLabel;
@property (nonatomic, weak) IBOutlet UISwitch *userTokenSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *forceRenewalSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *customTransitionSwitch;

@end

@implementation DomainViewController

#pragma mark Accessors and mutators

- (void)setDomain:(NSString *)domain
{
    _domain = domain;
    
    self.title = [NSString stringWithFormat:@"%@ (%@)", NameForDomain(domain), domain];
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self reloadData];
}

#pragma mark UI

- (void)reloadData
{
    CPAToken *token = [[CPAProvider defaultProvider] tokenForDomain:self.domain];
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
    CPAToken *existingToken = [[CPAProvider defaultProvider] tokenForDomain:self.domain];
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
        credentialsPresentationBlock = ^(UIViewController *viewController, CPAPresentationAction action) {
            if (action == CPAPresentationActionShow) {
                [self.navigationController pushViewController:viewController animated:YES];
            }
            else {
                [self.navigationController popViewControllerAnimated:YES];
            }
        };
    }
    
    CPATokenType type = self.userTokenSwitch.on ? CPATokenTypeUser : CPATokenTypeClient;
    [[CPAProvider defaultProvider] requestTokenForDomain:self.domain withType:type credentialsPresentationBlock:credentialsPresentationBlock completionBlock:^(CPAToken *token, NSError *error) {
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
