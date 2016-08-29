//
//  Alert.swift
//  MazazineReader
//
//  Created by Oleksii Nezhyborets on 29.08.16.
//  Copyright © 2016 Onix-Systems. All rights reserved.
//

import UIKit

struct Alert {
    static func error(message: String, controller: UIViewController) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(action)
        controller.presentViewController(alertController, animated: true, completion: nil)
    }
    
    static func error(error: NSError, controller: UIViewController) {
        self.error(error.localizedDescription, controller: controller)
    }
}
