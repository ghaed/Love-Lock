//
//  FacebookGalleryVC.swift
//  FinalProj
//
//  Created by Saeedeh Salimian on 7/31/16.
//  Copyright © 2016 hassaninc. All rights reserved.
//

import Foundation
import Alamofire


class FacebookGalleryVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, PictureBatchDownloadDelegate, FacebookGalleryModelChangeDelegate {
    /****** OUTLETS ******/
    @IBOutlet weak var userCommitedEdit: UIButton!
    @IBOutlet weak var collection: UICollectionView!
    
    /****** ACTIONS ******/
    @IBAction func userCommitedEditTouchUp(sender: AnyObject) {
//        let downloader = ImageDownloader()
//        let URLRequest = NSURLRequest(URL: NSURL(string: "https://httpbin.org/image/jpeg")!)
//        downloader.downloadImage(URLRequest: URLRequest) { response in
//            if let image = response.result.value {
//                print(image)
//            }
//        }
        pictureBatchDownload.clear()
        //selectedPicturesUrls = [facebookGalleryModel[0]!, facebookGalleryModel[1]!] // Todo: replace with actual urls
        pictureBatchDownload.urls = facebookGalleryModel.checkedUrls
        pictureBatchDownload.startDownload()
        
    }
    
    func pictureBatchDownloadDone() {
        commitEdit?(pictureBatchDownload.pictures)    // Todo: replace with actual images
        navigationController?.popViewControllerAnimated(true)
    }
    
    /***** DELEGATES *****/
    var commitEdit: ([UIImage] -> Void)?
    
    /****** VARIABLES ******/
    var facebookGalleryModel = FacebookGalleryModel()
    var pictureBatchDownload = PictureBatchDownload()   // Helper class to download batch of pictures asynchronosly
    var selectedPicturesUrls = [String]()
    
    /****** CONSTANTS ******/
    let cellsPerRow = 2 // TODO: Promote as constants
    let gapSize: CGFloat = 5.0
    
    /****** UICOLLECTIONVIEW ******/
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("Enter Fcebook Gallery, row: \(indexPath.row)")
//        guard let cell = collection.cellForItemAtIndexPath(indexPath) as? ImageCellAsync else {
//            print("Could not cast cell as ImageCellAsync")
//            return
//        }
        facebookGalleryModel.toggleItemAtIndex(indexPath.row)
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let imageResource = facebookGalleryModel[indexPath.row] else {
            print("Bug, Invalid index: \(indexPath.row)")
            return UICollectionViewCell()
        }
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ImageCellAsync.StoryboardID, forIndexPath: indexPath) as? ImageCellAsync else {
            print("Bug, Could not create cell \(ImageCellAsync.StoryboardID)!")
            return UICollectionViewCell()
        }
        if cell.resourceRepresented == imageResource { // It already has the right value!
            return cell
        }
        
        cell.imageDelayed(imageResource)
        // REF: http://stackoverflow.com/questions/28636622/how-to-load-image-in-swift-using-alamofire
        Alamofire.request(.GET, imageResource).response { (request, response, data, error) in
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
            cell.imageArrived(imageResource, image: img)
            print("loading image")
        }
        cell.isChecked = facebookGalleryModel.checkedArray[indexPath.row]
        return cell
    }
    
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let totalGapsPerRow = cellsPerRow * 2 // Insets are on the left & right of each cell
        let totalGapWidth = CGFloat(totalGapsPerRow) * gapSize
        let cellDim = (collectionView.frame.width - totalGapWidth) / CGFloat(cellsPerRow)
        return CGSize(width: cellDim, height: cellDim)
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: gapSize, left: gapSize, bottom: gapSize, right: gapSize)
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return gapSize
    }
    
    
    // MARK: UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return facebookGalleryModel.count
    }
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func facebookGalleryModelDataChanged() {
        updateUI()
    }
    
    func updateUI() {
        collection.reloadData()
    }
    
    // MARK: Other methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        pictureBatchDownload.delegate = self
        facebookGalleryModel.delegate = self
    }

    
}
