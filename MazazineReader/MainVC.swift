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
    fileprivate enum SegueIdentifier: String {
        case Auth = "authSegue"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        FIRAuth.auth()?.addStateDidChangeListener({ (auth, user) in
            DispatchQueue.main.async(execute: {
                if let uUser = user {
                    
                } else {
                    self.performSegue(withIdentifier: SegueIdentifier.Auth.rawValue, sender: nil)
                }
            })
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let identifier = segue.identifier, let segueIdentifier = SegueIdentifier(rawValue: identifier) {
            switch segueIdentifier {
            case .Auth:
                
                break
            }
        }
    }
}
