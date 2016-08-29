//
//  MainVC.swift
//  MazazineReader
//
//  Created by Oleksii Nezhyborets on 19.08.16.
//  Copyright © 2016 Onix-Systems. All rights reserved.
//

import UIKit
import FirebaseAuth

class MainVC: UISplitViewController {
    private enum SegueIdentifier: String {
        case Auth = "authSegue"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        FIRAuth.auth()?.addAuthStateDidChangeListener({ (auth, user) in
            dispatch_async(dispatch_get_main_queue(), {
                if let uUser = user {
                    
                } else {
                    self.performSegueWithIdentifier(SegueIdentifier.Auth.rawValue, sender: nil)
                }
            })
        })
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
