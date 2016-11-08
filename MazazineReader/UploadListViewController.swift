//
//  UploadListViewController.swift
//  MazazineReader
//
//  Created by Oleksii Nezhyborets on 29.08.16.
//  Copyright © 2016 Onix-Systems. All rights reserved.
//

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
        if let client = Dropbox.authorizedClient {
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
            case .Success(_):
                self.actOnDropboxCurrentAuthorizationStatus()
            case .Error(let error):
                Alert.error(error, controller: self)
            }
        }
    }
    
    fileprivate func proceedWithClient(_ client: DropboxClient) {
        self.client = client
        HUD.show(.Progress)
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
        Dropbox.authorizeFromController(self)
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
        let dropboxUrl = documentsUrl.appendingPathComponent(documentsUrl.path)
        let dropboxFolderPath = dropboxUrl.path
        
        var needToCreateFolder = false
        var isDir : ObjCBool = false
        if FileManager.default.fileExists(atPath: dropboxFolderPath, isDirectory: &isDir) {
            if !isDir {
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
                
            }
        }
        
        let fileUrl = URL.fileURLWithPathComponents([documentsPath,"dropbox",entry.pathLower])!
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
        
        if FileManager.defaultManager().fileExistsAtPath(fileUrl.path!) {
            self.goToDetailsWithPath(fileUrl.path!)
            return
        }
        
        HUD.show(.Progress)
        client.files.download(path: entry.pathLower, destination: localURLClosureForEntry(entry)).response { (fileMetadata, error) in
            DispatchQueue.main.async(execute: {
                print("data \(fileMetadata)")
                print("error \(error)")
                
                HUD.hide()
                if let uError = error {
                    Alert.error(uError.description, controller: self)
                    return
                }
                
                self.goToDetailsWithPath(fileUrl.path!)
            })
        }
        
    }
}
