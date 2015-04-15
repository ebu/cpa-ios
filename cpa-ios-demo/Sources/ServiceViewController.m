//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "ServiceViewController.h"

#import "CPAProvider.h"

NSString *NameForService(NSString *serviceIdentifier)
{
    static NSDictionary *s_names = nil;
    static dispatch_once_t s_onceToken;
    dispatch_once(&s_onceToken, ^{
        s_names = @{ @"playlist" : NSLocalizedString(@"Playlist", nil),
                     @"hbbtv" : NSLocalizedString(@"HbbTV", nil) };
    });
    return s_names[serviceIdentifier] ?: @"unknown";
}

NSString *DomainForService(NSString *serviceIdentifier)
{
    static NSDictionary *s_domains = nil;
    static dispatch_once_t s_onceToken;
    dispatch_once(&s_onceToken, ^{
        s_domains = @{ @"playlist" : @"playlist.rts.ch",
                       @"hbbtv" : @"hbbtv.rts.ch" };
    });
    return s_domains[serviceIdentifier] ?: @"unknown";
}

@interface ServiceViewController ()

@property (nonatomic, weak) IBOutlet UILabel *tokenLabel;
@property (nonatomic, weak) IBOutlet UISwitch *userTokenSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *forceRenewalSwitch;
@property (nonatomic, weak) IBOutlet UISwitch *customTransitionSwitch;

@end

@implementation ServiceViewController

#pragma mark Accessors and mutators

- (void)setServiceIdentifier:(NSString *)serviceIdentifier
{
    _serviceIdentifier = serviceIdentifier;
    
    self.title = [NSString stringWithFormat:@"%@ (%@)", NameForService(serviceIdentifier), DomainForService(serviceIdentifier)];
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
    CPAToken *token = [[CPAProvider defaultProvider] tokenForDomain:DomainForService(self.serviceIdentifier)];
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
    CPAToken *existingToken = [[CPAProvider defaultProvider] tokenForDomain:DomainForService(self.serviceIdentifier)];
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
    [[CPAProvider defaultProvider] requestTokenForDomain:DomainForService(self.serviceIdentifier) withType:type credentialsPresentationBlock:credentialsPresentationBlock completionBlock:^(CPAToken *token, NSError *error) {
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
