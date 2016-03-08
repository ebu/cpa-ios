//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

private func nameForDomain(domain: String!) -> String? {
    struct Static {
        static let names = [
            "playlist.rts.ch" : NSLocalizedString("RTSPlaylist", comment: ""),
            "hbbtv.rts.ch" : NSLocalizedString("TS HbbTV", comment: ""),
            "unsupported.ch" : NSLocalizedString("Unsupported domain", comment: "")
        ]
    }
    return Static.names[domain]
}

class DomainViewController: UIViewController {
    
    // MARK: Accessors and mutators
    
    var domain: String! {
        didSet {
            if let name = nameForDomain(domain) {
                self.title = "\(name) (\(domain))"
            }
            else {
                self.title = nil
            }
        }
    }
    
    @IBOutlet private weak var tokenLabel: UILabel!
    @IBOutlet private weak var userTokenSwitch: UISwitch!
    @IBOutlet private weak var forceRenewalSwitch: UISwitch!
    @IBOutlet private weak var customTransitionSwitch: UISwitch!
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.reloadData()
    }
    
    // MARK: UI
    
    func reloadData() {
        if let token = CPAProvider.defaultProvider()?.tokenForDomain(self.domain) {
            let tokenTypeString = (token.type == CPATokenType.Client) ? NSLocalizedString("Client", comment: "") : NSLocalizedString("User", comment: "")
            self.tokenLabel.text = "\(token.value)\n(\(tokenTypeString))"
        }
        else {
            self.tokenLabel.text = NSLocalizedString("None", comment: "")
        }
    }
    
    // MARK: Actions
    
    @IBAction func retrieveToken(sender: UIButton) {
        let existingToken = CPAProvider.defaultProvider()?.tokenForDomain(self.domain)
        if (existingToken != nil && !self.forceRenewalSwitch.on) {
            let alertView = UIAlertView(title: NSLocalizedString("Information", comment: ""), message: NSLocalizedString("A token is already available", comment: ""), delegate: nil, cancelButtonTitle: NSLocalizedString("Dismiss", comment: ""))
            alertView.show()
            return
        }
        
        var credentialsPresentationBlock: CPACredentialsPresentationBlock? = nil
        if (self.customTransitionSwitch.on) {
            credentialsPresentationBlock = { (viewController, action) -> Void in
                if (action == CPAPresentationAction.Show) {
                    self.navigationController?.pushViewController(viewController, animated: true)
                }
                else {
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }
        }
        
        let type = self.userTokenSwitch.on ? CPATokenType.User : CPATokenType.Client
        CPAProvider.defaultProvider()?.requestTokenForDomain(domain, withType: type, credentialsPresentationBlock: credentialsPresentationBlock, completionBlock: { (token, error) -> Void in
            if (error != nil) {
                let alertView = UIAlertView(title: NSLocalizedString("Error", comment: ""), message: error?.localizedDescription, delegate: nil, cancelButtonTitle: NSLocalizedString("Dismiss", comment: ""))
                alertView.show()
                return
            }
            
            self.reloadData()
        })
    }
}
