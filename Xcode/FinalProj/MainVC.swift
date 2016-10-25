//
//  ViewController.swift
//  FinalProj
//
//  Created by Saeedeh Salimian on 7/30/16.
//  Copyright © 2016 hassaninc. All rights reserved.
//

import UIKit
import Alamofire
class MainVC: UIViewController, FBSDKLoginButtonDelegate, ModelChangeDelegate, UICollectionViewDataSource, UICollectionViewDelegate  {
    /****** OUTLETS ******/
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var scrapImage: UIImageView!
    
    /****** VARIABLES ******/
//    let downloader = ImageDownloader()
    var socialPhotoCollection = [UIImage]()
    var urls = [String]()
    
    private var localGallery: LocalGalleryModel = {
        NSLog("Building initial model")
        let t = LocalGalleryModel()
        // Some initial local images for debug
        for index in 1..<5 {
            guard let pic = UIImage(named: "portrait0\(index)") else {
                print("Initial local portrait not found")
                continue
            }
            //t.insertImageAtEnd(pic)   // This is handled inside LocalGalleryModel persistence code now
        }
        
        NSLog("Done building initial model")
        return t
    }()
    
    
    /****** MODEL DELEGATES ******/
    func modelDataChanged() {
        // TODO: fill
        print("Local Gallery Model informed through delegate of some change")
        updateUI()
    }
    
    
    
    /****** CUSTOM UI ELEMENTS******/
    let loginButton: FBSDKLoginButton = {
        let button = FBSDKLoginButton()
        // https://developers.facebook.com/docs/facebook-login/permissions
        // Apparently, only email and friends are made available to an App without Facebook review. User_photos requires Facebook review. You still might be able to run it on your own machine if you create a new Facebook App ID as the owner of the new app so that you can access your uploaded pictures
        button.readPermissions = ["email", "user_friends", "user_photos"]
        return button
    }()
    

    
    /****** FACEBOOK SDK METHODS ******/
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("Completed Login")
        //fetchProfile()
        fetchUrls()
    }
    
    func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }

    
    /****** UICOLLECTIONVIEW METHODS ******/
    // MARK: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("Enter, row: \(indexPath.row)")
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let imageResource = localGallery.getImageAtIndex(indexPath.row) else {
            print("Invalid index in local Image collection")
            return UICollectionViewCell()
        }
        guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ImageCell.StoryboardID, forIndexPath: indexPath) as? ImageCell else {
            print("Bug: Could not create cell \(ImageCell.StoryboardID)!")
            return UICollectionViewCell()
        }
        
        cell.setImage(imageResource)
        
        return cell
    }
    
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let totalGapsPerRow = LocalGalleryModel.cellsPerRow * 2 // Insets are on the left & right of each cell
        let totalGapWidth = CGFloat(totalGapsPerRow) * LocalGalleryModel.gapSize
        let cellDim = (collectionView.frame.width - totalGapWidth) / CGFloat(LocalGalleryModel.cellsPerRow)
        return CGSize(width: cellDim, height: cellDim)
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: LocalGalleryModel.gapSize, left: LocalGalleryModel.gapSize, bottom: LocalGalleryModel.gapSize, right: LocalGalleryModel.gapSize)
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return LocalGalleryModel.gapSize
    }
    
    
    // MARK: UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return localGallery.numberOfPictures
    }
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    /****** NAVIGATION ******/
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("Preparing to segue to Facebook Gallery VC")
        guard let facebookGalleryVC = segue.destinationViewController as? FacebookGalleryVC else {
            preconditionFailure("Wrong destination type: \(segue.destinationViewController)")
        }
        
        
        facebookGalleryVC.facebookGalleryModel.reloadAllUrls(self.urls)     // Passing on extracted URLs to new VC
        facebookGalleryVC.commitEdit = { (newLocalPictures: [UIImage]) in
            //self.nameModel.update(atIndex: editingRow, value: newName)      
            // Todo: Building the new local gallery
            self.localGallery.reloadAllImages(newLocalPictures)
        }
        
        
    }
    

    /****** OTHER METHODS ******/
    func fetchProfile() {
        print("Fetching profile")
        let parameters = ["fields": "email, first_name, last_name, picture.type(large)"]
        FBSDKGraphRequest(graphPath: "me", parameters: parameters).startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if error != nil {
                print(error)
                return
            }
            
            if let email = result["email"] as? String {
                print(email)
            }
            
            if let picture = result["picture"] as? NSDictionary, data = picture["data"] as? NSDictionary, url = data["url"] as? String {
                print(url)
            }
            }
            )
    }
    
    
    
    
    
    func fetchUrls() {
        
        // REF: http://stackoverflow.com/questions/30173236/get-array-of-facebook-albums-in-swift-using-facebook-sdk-4-1
        // ref: https://helloswift.wordpress.com/2015/07/11/build-a-facebook-album-browser-using-swift-2/
        print("Fetching all images")
        let parameters = ["fields": "id, name, source"]
        FBSDKGraphRequest(graphPath: "me/photos", parameters: parameters).startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if error != nil {
                print(error)
                return
            }
            
            
            guard let photos = result["data"] as? NSArray else {
                print("could not convert photos to array")
                return
            }
            
            self.urls.removeAll()
            
            for item in photos {
                guard let urlStringItem = item["source"] else {
                    print("could not get url String in dictionary")
                    return
                }
                
                guard let urlString = urlStringItem as? String else {
                    print("could not convert urlString to string")
                    return
                }
                
                self.urls.append(urlString)
                
//                guard let url = NSURL(string: urlString) else {
//                    print("could not convert URL to NSURL")
//                    return
//                }
//                guard let imageData = NSData(contentsOfURL: url) else {
//                    print("could not grab image data from URL")
//                    return
//                }
//                guard let image = UIImage(data: imageData) else {
//                    print("could not covert image data to UIImage")
//                    return
//                }
                
                
                print("added the \(self.urls.count)th URL to the list of photo URLs to be transferred via segue")
//                self.socialPhotoCollection.append(image)
            }
            
            //REF: http://stackoverflow.com/questions/27604192/ios-how-to-segue-programmatically-using-swift
            print("added \(self.urls.count) image URLs to be transferred via segue")
            self.performSegueWithIdentifier("segueToFacebookGallery", sender: self)
            }
        )
    }
    

    
    func updateUI() {
        collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        localGallery.delegate = self
        
        // REF: https://www.youtube.com/watch?v=MNfrBdyEvmY
        view.addSubview(loginButton)
        loginButton.center = view.center
        loginButton.center.x = view.center.x*15/10
        loginButton.center.y = view.center.y/4
        loginButton.delegate = self
        
        if let _ = FBSDKAccessToken.currentAccessToken() {
            //fetchProfile()
            //fetchPictures()
        }
        
        
        // REF: http://stackoverflow.com/questions/28636622/how-to-load-image-in-swift-using-alamofire
//        Alamofire.request(.GET, "https://robohash.org/123.png").response { (request, response, data, error) in
//            self.scrapImage.image = UIImage(data: data!, scale:1)
//        }
        
        
        // REF: https://github.com/Alamofire/AlamofireImage
//        let URLRequest = NSURLRequest(URL: NSURL(string: "https://robohash.org/123.png")!)
//        downloader.downloadImage(URLRequest: URLRequest) { response in
//            print("hello")
//            if let image = response.result.value {
//                print(image)
//                self.scrapImage.image = image
//            }
//        }
        
//        let URLRequest = [NSURLRequest(URL: NSURL(string: "https://robohash.org/123.png")!), NSURLRequest(URL: NSURL(string: "https://robohash.org/122.png")!)]
//        downloader.downloadImages(URLRequests: URLRequest) { response in
//            print("hello")
//            if let image = response.result.value {
//                print(image)
//                self.scrapImage.image = image
//            }
//        }


        
        
        
        
    }
    
}

