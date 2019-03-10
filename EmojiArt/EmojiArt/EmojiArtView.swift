//
//  EmojiArtView.swift
//  EmojiArt
//
//  Created by xu on 3/3/19.
//  Copyright © 2019 xu. All rights reserved.
//

import UIKit

class EmojiArtView: UIView {

    var backgroundImage: UIImage?{
        didSet{setNeedsDisplay()}
    }

    override func draw(_ rect: CGRect) {
        backgroundImage?.draw(in: bounds)
    }
 

}
