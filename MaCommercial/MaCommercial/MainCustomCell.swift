//
//  MainCustomCell.swift
//  MaCommercial
//
//  Created by iem on 10/06/2015.
//  Copyright (c) 2015 Sarah LAFORETS. All rights reserved.
//

import UIKit

class MainCustomCell: SWTableViewCell {
    
    override func awakeFromNib() {
        //Stylize cell background
        self.backgroundColor =  UIColor.clearColor()
        var effect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        var effectStyle = UIVisualEffectView(effect: effect)
        self.backgroundView = effectStyle
    }
    
}

