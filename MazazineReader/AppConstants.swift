//
//  AppConstants.swift
//  MazazineReader
//
//  Created by Oleksii Nezhyborets on 29.08.16.
//  Copyright © 2016 Onix-Systems. All rights reserved.
//

import Foundation
import SwiftyDropbox

struct AppConstants {
    static let ErrorDomain = NSBundle.mainBundle().bundleIdentifier!
}

enum Result<T : Any> {
    case Success(T)
    case Error(NSError)
}

enum ErrorCode: Int {
    case DropboxLogin
}

struct DropboxDidLoginNotification {
    static let Name = "DropboxDidLoginNotification"
    static let TokenKey = "kToken"
    static let ErrorKey = "kError"
    static let ErrorDescriptionKey = "kErrorDescription"
    
    static func resultFromNotification(notification: NSNotification) -> Result<DropboxAccessToken> {
        if let errorDescription = notification.userInfo?[ErrorDescriptionKey] as? String {
            let error = NSError(domain: AppConstants.ErrorDomain, code: ErrorCode.DropboxLogin.rawValue, userInfo: [NSLocalizedDescriptionKey : errorDescription])
            return .Error(error)
        }
        
        let token = notification.userInfo![TokenKey] as! DropboxAccessToken
        return .Success(token)
    }
}