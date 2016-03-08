//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

class DomainsViewController: UITableViewController {
    
    // MARK: Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let domainViewController = segue.destinationViewController as! DomainViewController
        domainViewController.domain = segue.identifier
    }
}

