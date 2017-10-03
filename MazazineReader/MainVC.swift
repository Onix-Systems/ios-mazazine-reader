// Copyright 2017 Onix-Systems

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
    
    @IBAction func unwindToMainVC(sender: UIStoryboardSegue)
    {
        let sourceViewController = sender.source
        // Pull any data from the view controller which initiated the unwind segue.
        
    }
}
