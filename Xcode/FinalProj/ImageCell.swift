//
//  ImageCell.swift
//  FinalProj
//
//  Created by Saeedeh Salimian on 7/31/16.
//  Copyright © 2016 hassaninc. All rights reserved.
//

import Foundation

class ImageCell: UICollectionViewCell {
    static let StoryboardID = "Image Collection View Cell"
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        buildView()
    }
    
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        buildView()
    }
    
    private func buildView() {
        layer.backgroundColor = UIColor.lightGrayColor().CGColor
        addSubview(imageView)
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
    }
    
    
    private var imageView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .ScaleAspectFit
        return v
    }()
    
    func setImage(image: UIImage) {
        self.imageView.image = image
    }
    
}