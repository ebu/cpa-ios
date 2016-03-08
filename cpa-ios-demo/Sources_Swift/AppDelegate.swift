//
//  Copyright (c) European Broadcasting Union. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    // MARK: Application lifecycle
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let providerURL = NSURL(string: "https://cpa.rts.ch")
        let provider = CPAProvider(authorizationProviderURL: providerURL!)
        CPAProvider.setDefaultProvider(provider)
        
        return true
    }
}
