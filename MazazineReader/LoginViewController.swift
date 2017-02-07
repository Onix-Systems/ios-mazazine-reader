//
//  LoginViewController.swift
//  MazazineReader
//
//  Created by Oleksii Nezhyborets on 19.08.16.
//  Copyright © 2016 Onix-Systems. All rights reserved.
//

import UIKit
import FirebaseAuth
import PKHUD
import SCLAlertView
import GoogleSignIn
import Eureka

class LoginViewController: FormViewController, GIDSignInUIDelegate {
    private enum Segue : String {
        case unwind = "unwindToMainVC"
    }
    
    enum LoginFormTag : String {
        case Email
        case Password
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        
        form
            +++ Section("Login with email")
            <<< EmailRow(LoginFormTag.Email.rawValue){ row in
                row.title = "E-mail"
                row.placeholder = "Enter email here"
            }
            <<< PasswordRow(LoginFormTag.Password.rawValue) {
                $0.title = "Password"
                $0.placeholder = "and password here"
            }
            <<< ButtonRow() { row in
                row.title = "Login"
            }.onCellSelection({ [weak self] (cell, row) in
                self?.login()
            })
            <<< ButtonRow() { row in
                row.title = "Create account"
            }.onCellSelection({ [weak self] (cell, row) in
                self?.createAccount()
            })
            
            +++ Section("Social login")
            <<< ButtonRow("Login with Google") { row in
                row.title = "Login with Google"
            }.onCellSelection({ [weak self] (cell, row) in
                self?.loginWithGoogle()
            })
    }
    
    func login() {
        if let email = email(), let password = password() {
            HUD.show(.progress)
            FIRAuth.auth()!.signIn(withEmail: email, password: password, completion: { (user, error) in
                self.handleAuthResult(user, error: error)
            })
        }
    }
    
    func createAccount() {
        if let email = email(), let password = password() {
            HUD.show(.progress)
            FIRAuth.auth()!.createUser(withEmail: email, password: password) { (user, error) in
                self.handleAuthResult(user, error: error)
            }
        }
    }
    
    func loginWithGoogle() {
        GIDSignIn.sharedInstance().signIn()
    }
    
    func email() -> String? {
        guard let emailRow = form.rowBy(tag: LoginFormTag.Email.rawValue) as? EmailRow, let email = emailRow.value else {
            print("wft")
            return nil
        }
        
        return email
    }
    
    func password() -> String? {
        guard let passwordRow = form.rowBy(tag: LoginFormTag.Password.rawValue) as? PasswordRow, let password = passwordRow.value else {
            print("wtf")
            return nil
        }
        
        return password
    }
    
    fileprivate func handleAuthResult(_ user: FIRUser?, error: Error?) {
        DispatchQueue.main.async {
            if let uError = error {
                HUD.hide()
                SCLAlertView().showError("Error", subTitle: uError.localizedDescription)
            } else {
                HUD.flash(.success, delay: 1.0)
                self.performSegue(withIdentifier: Segue.unwind.rawValue, sender: self)
            }
        }
    }
}

extension LoginViewController : GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let uError = error {
            SCLAlertView().showError("Error", subTitle: uError.localizedDescription)
        } else {
            let auth = user.authentication
            let credential = FIRGoogleAuthProvider.credential(withIDToken: (auth?.idToken)!, accessToken: (auth?.accessToken)!)
            HUD.show(.progress)
            FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
                self.handleAuthResult(user, error: error)
                return
            })
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        self.handleAuthResult(nil, error: error)
    }
}
