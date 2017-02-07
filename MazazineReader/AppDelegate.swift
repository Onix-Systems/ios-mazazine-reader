//
//  AppDelegate.swift
//  MazazineReader
//
//  Created by Oleksii Nezhyborets on 19.08.16.
//  Copyright © 2016 Onix-Systems. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import SwiftyDropbox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        splitViewController.delegate = self
        FIRApp.configure()
        
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        DropboxClientsManager.setupWithAppKey(Keys.dropboxAppKey)
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        handleDropbox(openURL: url)
        
        return GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        handleDropbox(openURL: url)
        
        return GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    fileprivate func handleDropbox(openURL url: URL) {
        if let authResult = DropboxClientsManager.handleRedirectURL(url) {
            switch authResult {
            case .success(let token):
                print("Success! User is logged into Dropbox with token: \(token)")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: DropboxDidLoginNotification.Name), object: nil, userInfo: [DropboxDidLoginNotification.TokenKey : token])
            case .error(let error, let description):
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: DropboxDidLoginNotification.Name), object: nil, userInfo: [DropboxDidLoginNotification.ErrorDescriptionKey : description])
                print("Error \(error): \(description)")
            case .cancel:
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: DropboxDidLoginNotification.Name), object: nil, userInfo: [DropboxDidLoginNotification.ErrorDescriptionKey : "User cancelled"])
            }
        }
    }
    
    // MARK: - Split view
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else { return false }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController else { return false }
        if topAsDetailController.detailItem == nil {
            // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            return true
        }
        return false
    }

}

