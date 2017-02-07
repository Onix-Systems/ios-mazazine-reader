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
    static let ErrorDomain = Bundle.main.bundleIdentifier!
}

enum Result<T : Any> {
    case success(T)
    case error(NSError)
}

enum ErrorCode: Int {
    case dropboxLogin
}

struct DropboxDidLoginNotification {
    static let Name = "DropboxDidLoginNotification"
    static let TokenKey = "kToken"
    static let ErrorKey = "kError"
    static let ErrorDescriptionKey = "kErrorDescription"
    
    static func resultFromNotification(_ notification: Notification) -> Result<DropboxAccessToken> {
        if let errorDescription = notification.userInfo?[ErrorDescriptionKey] as? String {
            let error = NSError(domain: AppConstants.ErrorDomain, code: ErrorCode.dropboxLogin.rawValue, userInfo: [NSLocalizedDescriptionKey : errorDescription])
            return .error(error)
        }
        
        let token = notification.userInfo![TokenKey] as! DropboxAccessToken
        return .success(token)
    }
}
