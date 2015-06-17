
//
//  ListPresentationCollectionViewCell.swift
//  MaCommercial
//
//  Created by iem on 05/06/2015.
//  Copyright (c) 2015 Sarah LAFORETS. All rights reserved.
//

import UIKit

class ListPresentationCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imagePresentation: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func layoutSubviews() {
        self.titleLabel.layer.borderColor = UIColor(red: 170/255.0, green: 0, blue: 0, alpha: 1).CGColor
        self.titleLabel.layer.borderWidth = 1
    }
    
}
