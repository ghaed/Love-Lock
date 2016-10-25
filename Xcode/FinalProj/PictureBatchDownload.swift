//
//  PictureBatchDownload.swift
//  FinalProj
//
//  Created by Saeedeh Salimian on 8/2/16.
//  Copyright © 2016 hassaninc. All rights reserved.
//

import Foundation
import Alamofire

enum PictureBatchStatus {
    case Idle,
    Downloading,
    Updated
}

protocol PictureBatchDownloadDelegate {
    func pictureBatchDownloadDone()
}

class PictureBatchDownload {
    var pictures = [UIImage]()
    var urls = [String]()
    var numberOfFiles: Int {
        get {
            return urls.count
        }
    }
    var numberOfFilesDownloaded = 0 {
        didSet {
            if numberOfFiles == 0 {
                print("PictureBatchDownload: false trigger of didset when urls is empty")
                return
            }
            if numberOfFiles == numberOfFilesDownloaded {
                print("PictureBatchDownload: Done downloading \(self.numberOfFiles) files")
                print("calling delegate")
                delegate?.pictureBatchDownloadDone()
            }
        }
    }
    
    var status: PictureBatchStatus = .Idle
    var totalDownloadCount = 0
    
    
    var delegate: PictureBatchDownloadDelegate? {
        didSet {
            if let _ = delegate {
                NSLog("From now on, will propagate messages to delegate \(delegate)")
            }
            else {
                NSLog("Delegate cleared")
            }
        }
    }
    
    func clear() {
        self.pictures.removeAll()
        self.status = .Idle
        self.numberOfFilesDownloaded = 0
    }
    
    func startDownload() {
        self.clear()
        self.status = .Downloading
        guard urls.count > 0 else {
            print ("Batch Downloader: No URLs passed")
            return
        }

        for url in urls {
            Alamofire.request(.GET, url).response { (request, response, data, error) in
                guard NSThread.isMainThread() else {
                    print("Bug. Not on the main thread, fix the network layer")
                    return
                }
                guard let data_unwrapped = data  else {
                    print("Could not unwrap network-received data")
                    return
                }
                guard let img = UIImage(data: data_unwrapped,scale: 1) else {
                    print("could not make an image out of network-received data")
                    return
                }
                self.pictures.append(img)
                self.numberOfFilesDownloaded += 1
                
                print("Picturebatchdownload: loaded image \(self.numberOfFilesDownloaded) out of \(self.numberOfFiles) to internal image array")
            }
        }
    }
    
}