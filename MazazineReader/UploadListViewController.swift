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
import SwiftyDropbox
import PKHUD
import vfrReader

class UploadListViewController: UIViewController {
    fileprivate var entries : [Files.Metadata] = []
    fileprivate var client : DropboxClient!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    fileprivate func setup() {
        NotificationCenter.default.addObserver(self, selector: #selector(onDropboxLoginFinished(_:)), name: NSNotification.Name(rawValue: DropboxDidLoginNotification.Name), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.actOnDropboxCurrentAuthorizationStatus()
    }
    
    fileprivate func actOnDropboxCurrentAuthorizationStatus() {
        if let client = DropboxClientsManager.authorizedClient {
            self.linkButton.isHidden = true
            self.tableView.isHidden = false
            self.proceedWithClient(client)
        } else {
            self.tableView.isHidden = true
        }
    }
    
    func onDropboxLoginFinished(_ notification: Notification) {
        DispatchQueue.main.async {
            let result = DropboxDidLoginNotification.resultFromNotification(notification)
            switch result {
            case .success(_):
                self.actOnDropboxCurrentAuthorizationStatus()
            case .error(let error):
                Alert.error(error, controller: self)
            }
        }
    }
    
    fileprivate func proceedWithClient(_ client: DropboxClient) {
        self.client = client
        HUD.show(.progress)
        client.files.listFolder(path: "").response { (response, error) in
            DispatchQueue.main.async(execute: {
                HUD.hide()
                if let result = response {
                    print(result)
                    
                    self.entries = result.entries
                    self.reload()
                } else {
                    Alert.error(error!.description, controller: self)
                }
            })
        }
    }
    
    @IBAction func linkButtonAction(_ sender: AnyObject) {
        let openUrl : (URL) -> () = { url in
            UIApplication.shared.openURL(url)
        }
        
        DropboxClientsManager.authorizeFromController(UIApplication.shared, controller: self, openURL: openUrl)
    }
    
    @IBOutlet weak var linkButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate func reload() {
        self.tableView.reloadData()
    }
    
    fileprivate func localURLClosureForEntry(_ entry: Files.Metadata) -> (URL, HTTPURLResponse) -> URL {
        let url = localURLForEntry(entry)
        return { _,_ in
            return url
        }
    }
    
    fileprivate func localURLForEntry(_ entry: Files.Metadata) -> URL {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let documentsUrl = URL(string: documentsPath)!
        let dropboxFolerUrl = documentsUrl.appendingPathComponent("dropbox")
        let dropboxFolderPath = dropboxFolerUrl.path
        
        var needToCreateFolder = false
        var isDir : ObjCBool = false
        if FileManager.default.fileExists(atPath: dropboxFolderPath, isDirectory: &isDir) {
            if isDir.boolValue {
                needToCreateFolder = true
                removeItemAtPath(dropboxFolderPath)
            }
        } else {
            needToCreateFolder = true
        }
        
        if (needToCreateFolder) {
            do {
                try FileManager.default.createDirectory(atPath: dropboxFolderPath, withIntermediateDirectories: false, attributes: nil)
            } catch let error as NSError {
                print(error)
            }
        }
        
        let fileUrl = NSURL.fileURL(withPathComponents: [dropboxFolderPath,entry.pathLower!])!
        return fileUrl
    }
    
    fileprivate func goToDetailsWithPath(_ path: String) {
        if let document = ReaderDocument(filePath: path, password: "") {
            let vc = FileDetailVC(readerDocument: document)!
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            Alert.error("File is not PDF. Please retry", controller: self)
            removeItemAtPath(path)
        }
    }
    
    fileprivate func removeItemAtPath(_ path: String) {
        do {
            try FileManager.default.removeItem(atPath: path)
        } catch let error as NSError {
            Alert.error(error, controller: self)
            return
        }
    }
}

extension UploadListViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.entries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "uploadCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let entry = entries[indexPath.row]
        cell.textLabel?.text = entry.name
        
        return cell
    }
}

extension UploadListViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let entry = entries[indexPath.row]
        
        let fileUrl = self.localURLForEntry(entry)
        
        if FileManager.default.fileExists(atPath: fileUrl.path) {
            self.goToDetailsWithPath(fileUrl.path)
            return
        }
        
        HUD.show(.progress)
        client.files.download(path: entry.pathLower!, destination: localURLClosureForEntry(entry)).response { (fileMetadata, error) in
            DispatchQueue.main.async(execute: {
                print("data \(fileMetadata)")
                print("error \(error)")
                
                HUD.hide()
                if let uError = error {
                    Alert.error(uError.description, controller: self)
                    return
                }
                
                self.goToDetailsWithPath(fileUrl.path)
            })
        }
        
    }
}
