//
//  EmojiArt_Gestures.swift
//  EmojiArt
//
//  Created by bitone on 2019/3/18.
//  Copyright © 2019 xu. All rights reserved.
//

import Foundation
import UIKit

extension EmojiArtView{
    
    var selectedView: UIView?{
        get{
            return subviews.filter{$0.layer.borderWidth == 2}.first
        }
        set{
            subviews.filter{$0.layer.borderWidth == 2}.forEach{$0.layer.borderWidth = 0}
            newValue?.layer.borderWidth = 2
            newValue?.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
    }
    
    func addEmojiArtGestureRecongizers(to targetView: UIView){
        //1. enable interactiable
        targetView.isUserInteractionEnabled = true
        //2. add tap gesture recognizer
        targetView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.selectSubview(by:))))
        targetView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(self.selectAndMoveSubview(by:))))
        //3. add pan gesture recognizer
    }
    
    
    @objc func selectSubview(by recongizer: UITapGestureRecognizer){
        print("tap gesture found on \(String(describing: (recongizer.view as? UILabel)?.text))")
        selectedView = recongizer.view
    }
    
    @objc func selectAndMoveSubview(by recognizer: UIPanGestureRecognizer){
        print("pan gesture found on \(String(describing: (recognizer.view as? UILabel)?.text))")
        switch recognizer.state {
        case .began:
             selectedView = recognizer.view
        case .changed:
            recognizer.view?.center = recognizer.view!.center.offset(by: recognizer.translation(in: self))
            recognizer.setTranslation(CGPoint.zero, in: self)
            
            //boardcast on emojiArtViewDidChange radio station
            NotificationCenter.default.post(name: .EmojiArtViewDidChange, object: self)
        case .ended:
            selectedView = nil
        default:
            break
        }
    }
}

extension CGPoint{
     func offset(by: CGPoint) -> CGPoint{
        return CGPoint(x: self.x + by.x, y: self.y + by.y)
    }
}
