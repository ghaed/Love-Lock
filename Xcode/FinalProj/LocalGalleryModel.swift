//
//  localGalleryModel.swift
//  FinalProj
//
//  Created by Saeedeh Salimian on 7/31/16.
//  Copyright © 2016 hassaninc. All rights reserved.
//

import Foundation

protocol ModelChangeDelegate {
    func modelDataChanged()
}


// Class to handle the local gallery model.
// These are images that are previously selected and downloaded
// from facebook and will be displayed on the main LoveLock window
class LocalGalleryModel {
    static let cellsPerRow = 2
    static let gapSize: CGFloat = 5.0
    

    
    
    var delegate: ModelChangeDelegate? {
        didSet {
            if let _ = delegate {
                NSLog("From now on, will propagate messages to delegate \(delegate)")
            }
            else {
                NSLog("Delegate cleared")
            }
        }
    }
    
    var numberOfPictures: Int {
        get {
            return pictures.count
        }
    }
    
    // The actual picutures stored in an array. These will be persisted to disk.
    private var pictures = [UIImage]() {
        didSet {
            NSLog("pictures property observer fired, informing delegate \(delegate)")
            delegate?.modelDataChanged()
            
            // Persistence
            guard pictures.count > 0 else {
                print("attempted to persist an empty image array to disk")
                return
            }
            
            // REF: http://stackoverflow.com/questions/6648518/save-images-in-nsuserdefaults
            print("Begining to persist new images to disk")
            let start = NSDate() // <<<<<<<<<< Start time
            NSUserDefaults.standardUserDefaults().setObject(uIImageArrayToPNGRepresentation(pictures), forKey: DefaultsKeys.pictures)
            let end = NSDate()  // <<<<<<<<<<   end time; 1122ms to save 25 images
            let timeIntervalms = Int(end.timeIntervalSinceDate(start)*1000) // <<<<< Difference in seconds (double)
            print("successfully persisted \(pictures.count) images to NSUserDefaults. Saving time: \(timeIntervalms)ms")

        }
    }
    
    func uIImageArrayToPNGRepresentation(images: [UIImage]) -> [NSData] {
        return images.map({UIImagePNGRepresentation($0)!})
    }
    func nSDataArrayToUIImageArray(imagesData: [NSData]) -> [UIImage] {
        return imagesData.map({UIImage(data: $0)!})
    }
    
    
    func insertImageAtIndex(image: UIImage, index: Int) {
        pictures.insert(image, atIndex: index)
    }
    
    func insertImageAtEnd(image: UIImage) {
        self.insertImageAtIndex(image, index: pictures.count)
    }
    
    func getImageAtIndex(index: Int) -> UIImage? {
        if index > pictures.count-1 {
            print("Requested for an image that does not exist")
            return nil
        }
        return pictures[index]
    }
    
    func reloadAllImages(newImages: [UIImage]) {
        self.pictures = newImages
    }

    //MARK: Persistence
    init() {
        if let savedLocalImagesData = NSUserDefaults.standardUserDefaults().valueForKey(DefaultsKeys.pictures) as? [NSData]  {
            print("App initialized. Loading previously-persisted data...")
            // REF: http://stackoverflow.com/questions/24755558/measure-elapsed-time-in-swift
            let start = NSDate() // <<<<<<<<<< Start time
            pictures = nSDataArrayToUIImageArray(savedLocalImagesData)      // The "as? [UIImage]" cast did not work directly, so, I had to do this back-flip
            let end = NSDate()  // <<<<<<<<<<   end time; 4ms to load 25 images
            
            let timeIntervalms = Int(end.timeIntervalSinceDate(start)*1000) // <<<<< Difference in seconds (double)
            print("Restored \(pictures.count) pictures from user defaults. Loading time: \(timeIntervalms)ms")
        }
        else {
            print("App initialized. Loading persisted data: no saved persisted data found. Using default vals")
            pictures = DefaultsValues.pictures
        }

    }
    
    
    
}