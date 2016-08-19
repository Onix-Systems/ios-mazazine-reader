//
//  MainVC.swift
//  MazazineReader
//
//  Created by Oleksii Nezhyborets on 19.08.16.
//  Copyright © 2016 Onix-Systems. All rights reserved.
//

import UIKit

class MainVC: UISplitViewController {
    private enum SegueIdentifier: String {
        case Auth = "authSegue"
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let loggedIn = true
        if loggedIn {
            dispatch_async(dispatch_get_main_queue(), {
                self.performSegueWithIdentifier(SegueIdentifier.Auth.rawValue, sender: nil)
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let identifier = segue.identifier, segueIdentifier = SegueIdentifier(rawValue: identifier) {
            switch segueIdentifier {
            case .Auth:
                
                break
            }
        }
    }
}
