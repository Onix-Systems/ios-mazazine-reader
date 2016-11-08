//
//  Alert.swift
//  MazazineReader
//
//  Created by Oleksii Nezhyborets on 29.08.16.
//  Copyright © 2016 Onix-Systems. All rights reserved.
//

import UIKit

struct Alert {
    static func error(_ message: String, controller: UIViewController) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(action)
        controller.present(alertController, animated: true, completion: nil)
    }
    
    static func error(_ error: NSError, controller: UIViewController) {
        self.error(error.localizedDescription, controller: controller)
    }
}
