//
//  ImageCellAsync.swift
//  FinalProj
//
//  Created by Saeedeh Salimian on 8/2/16.
//  Copyright © 2016 hassaninc. All rights reserved.
//

import Foundation

class ImageCellAsync: UICollectionViewCell {
    var isChecked: Bool = false {
        didSet {
            checkBox.hidden = !isChecked
        }
    }
    // MARK: Variables 
    static let StoryboardID = "Image Collection View Cell Async"
    
    // MARK: Custom Layout
    private var imageView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .ScaleAspectFit
        return v
    }()
    
    
    private var spinner: UIActivityIndicatorView = {
        let a = UIActivityIndicatorView(activityIndicatorStyle: .White)
        a.hidesWhenStopped = true
        a.hidden = false
        return a
    }()
    
    private var checkBox: UIImageView = {
        let c = UIImageView()
        c.image = UIImage(named: "checkbox")
        c.contentMode = .ScaleAspectFit
        c.hidden = true
        return c
    }()
    
    // MARK: State Machine Variables
    // Effectively a state machine in two variables: what image are we waiting on, and what image does this reusable cell currently display
    var resourceWaiting: String? {
        didSet {
            if resourceWaiting == nil {
                spinner.stopAnimating()
            }
            else {
                imageView.image = nil
                spinner.startAnimating()
            }
        }
    }
    
    
    var resourceRepresented: String? {
        didSet {
            guard let _ = resourceRepresented else {
                return
            }
        }
    }
    
    // MARK: Required methods for custom cell
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        buildView()
    }
    
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        buildView()
    }
    
    // MARK: view builder functions
    private func buildView() {
        layer.backgroundColor = UIColor.lightGrayColor().CGColor
        addSubview(imageView)
        addSubview(spinner)
        addSubview(checkBox)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        spinner.center = CGPoint(x: bounds.width / 2.0, y: bounds.height / 2.0)
        print("Center of spinner is \(center)")
        imageView.frame = bounds
        //checkBox.center = CGPoint(x: bounds.width / 4.0, y: bounds.height / 4.0)
        checkBox.frame = CGRect(x: 10.0, y: 10.0, width: 40.0, height: 40.0)
    }
    
    // MARK: functions manipulating the state machine
    func imageDelayed(imageResource: String) {
        resourceRepresented = nil
        resourceWaiting = imageResource
    }
    
    
    func imageArrived(imageResource: String, image: UIImage) {
        /* guard imageResource == resourceWaiting else {
         Util.log("Stale image arrived: \(imageResource), discarding.")
         return
         } */
        imageView.image = image
        resourceRepresented = imageResource
        resourceWaiting = nil
    }
    
}