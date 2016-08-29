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
    private var entries : [Files.Metadata] = []
    private var client : DropboxClient!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    private func setup() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onDropboxLoginFinished(_:)), name: DropboxDidLoginNotification.Name, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.actOnDropboxCurrentAuthorizationStatus()
    }
    
    private func actOnDropboxCurrentAuthorizationStatus() {
        if let client = Dropbox.authorizedClient {
            self.linkButton.hidden = true
            self.tableView.hidden = false
            self.proceedWithClient(client)
        } else {
            self.tableView.hidden = true
        }
    }
    
    func onDropboxLoginFinished(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue()) {
            let result = DropboxDidLoginNotification.resultFromNotification(notification)
            switch result {
            case .Success(_):
                self.actOnDropboxCurrentAuthorizationStatus()
            case .Error(let error):
                Alert.error(error, controller: self)
            }
        }
    }
    
    private func proceedWithClient(client: DropboxClient) {
        self.client = client
        HUD.show(.Progress)
        client.files.listFolder(path: "").response { (response, error) in
            dispatch_async(dispatch_get_main_queue(), {
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
    
    @IBAction func linkButtonAction(sender: AnyObject) {
        Dropbox.authorizeFromController(self)
    }
    
    @IBOutlet weak var linkButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    private func reload() {
        self.tableView.reloadData()
    }
    
    private func localURLClosureForEntry(entry: Files.Metadata) -> (NSURL, NSHTTPURLResponse) -> NSURL {
        let url = localURLForEntry(entry)
        return { _,_ in
            return url
        }
    }
    
    private func localURLForEntry(entry: Files.Metadata) -> NSURL {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let documentsUrl = NSURL(string: documentsPath)!
        let dropboxUrl = documentsUrl.URLByAppendingPathComponent(documentsUrl.path!)
        let dropboxFolderPath = dropboxUrl.path!
        
        var needToCreateFolder = false
        var isDir : ObjCBool = false
        if NSFileManager.defaultManager().fileExistsAtPath(dropboxFolderPath, isDirectory: &isDir) {
            if !isDir {
                needToCreateFolder = true
                removeItemAtPath(dropboxFolderPath)
            }
        } else {
            needToCreateFolder = true
        }
        
        if (needToCreateFolder) {
            do {
                try NSFileManager.defaultManager().createDirectoryAtPath(dropboxFolderPath, withIntermediateDirectories: false, attributes: nil)
            } catch let error as NSError {
                
            }
        }
        
        let fileUrl = NSURL.fileURLWithPathComponents([documentsPath,"dropbox",entry.pathLower])!
        return fileUrl
    }
    
    private func goToDetailsWithPath(path: String) {
        if let document = ReaderDocument(filePath: path, password: "") {
            let vc = FileDetailVC(readerDocument: document)!
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            Alert.error("File is not PDF. Please retry", controller: self)
            removeItemAtPath(path)
        }
    }
    
    private func removeItemAtPath(path: String) {
        do {
            try NSFileManager.defaultManager().removeItemAtPath(path)
        } catch let error as NSError {
            Alert.error(error, controller: self)
            return
        }
    }
}

extension UploadListViewController : UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.entries.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "uploadCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        let entry = entries[indexPath.row]
        cell.textLabel?.text = entry.name
        
        return cell
    }
}

extension UploadListViewController : UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let entry = entries[indexPath.row]
        
        let fileUrl = self.localURLForEntry(entry)
        
        if NSFileManager.defaultManager().fileExistsAtPath(fileUrl.path!) {
            self.goToDetailsWithPath(fileUrl.path!)
            return
        }
        
        HUD.show(.Progress)
        client.files.download(path: entry.pathLower, destination: localURLClosureForEntry(entry)).response { (fileMetadata, error) in
            dispatch_async(dispatch_get_main_queue(), {
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