//
//  FacebookGalleryModel.swift
//  FinalProj
//
//  Created by Saeedeh Salimian on 7/31/16.
//  Copyright © 2016 hassaninc. All rights reserved.
//

import Foundation

protocol FacebookGalleryModelChangeDelegate {
    func facebookGalleryModelDataChanged()
}


struct GalleryItem {
    var url = ""
    var isChecked = false
    
    init(url: String, isChecked: Bool) {
        self.isChecked = isChecked
        self.url = url
    }
}



// Class to handle Faceook Gallery model
// This is similar to ImageModel gallery in the ViewController
// example discussed in class. It basically indexes a user's 
// pictures by URL
class FacebookGalleryModel {
    var items = [GalleryItem]() {
        didSet {
            print("history property observer fired, informing delegate \(delegate)")
            delegate?.facebookGalleryModelDataChanged()
            
        }
    }
    
    
    
    //var urls = [String]()
    var urls: [String] {
        get {
            return items.map({$0.url})
        }
    }
    var checkedArray: [Bool] {
        get {
            return items.map({$0.isChecked})
        }
    }
    
    
    subscript(imageIndex: Int) -> String? {
        get {
            guard imageIndex < items.count else {
                return nil
            }
            // Names on server are 1-indexed
            return items[imageIndex].url
        }
    }
    
    
    var count: Int {
        get {
            return urls.count
        }
    }
    
    func reloadAllUrls(newUrls: [String]) {
        //self.urls = newUrls
        items = newUrls.map({GalleryItem(url: $0, isChecked: false)})
    }
    
    func toggleItemAtIndex(index: Int) {
        guard index < items.count else {
            print("asked to toggle non-existing item")
            return
        }
        items[index].isChecked = !items[index].isChecked
    }
    
    var checkedUrls: [String] {
        get {
            let filteredItems = items.filter({$0.isChecked == true})
            return filteredItems.map({$0.url})
        }
    }
    
    
    var delegate: FacebookGalleryModelChangeDelegate? {
        didSet {
            if let _ = delegate {
                NSLog("From now on, will propagate messages to delegate \(delegate)")
            }
            else {
                NSLog("Delegate cleared")
            }
        }
    }
}
