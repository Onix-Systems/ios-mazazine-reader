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
