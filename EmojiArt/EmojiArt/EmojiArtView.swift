//
//  EmojiArtView.swift
//  EmojiArt
//
//  Created by xu on 3/3/19.
//  Copyright © 2019 xu. All rights reserved.
//

import UIKit

class EmojiArtView: UIView , UIDropInteractionDelegate{

    //MARK: - setup dropInteraction
    override init(frame: CGRect) {
        super.init(frame:frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup(){
        addInteraction(UIDropInteraction(delegate: self))
    }
    

 

    //MARK: - drop interaction
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSAttributedString.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        session.loadObjects(ofClass: NSAttributedString.self) { providers in
            //1. get drop location
            let dropLocation = session.location(in: self)
            //2. go though every item
            for string in (providers as? [NSAttributedString] ?? []){
                //3. create UILabel at location with NSAttritubedString
                self.createLabel(withAttributedString: string, at: dropLocation)
            }
        }
    }
    
    //add new emoji to emojiArtView
    func createLabel(withAttributedString string:NSAttributedString, at centered:CGPoint){
        let newLabel = UILabel()
        newLabel.attributedText = string
        newLabel.sizeToFit()
        newLabel.center = centered
        addSubview(newLabel)
    }
    
    //MARK: - backgroundImage
    var backgroundImage: UIImage?{
        didSet{setNeedsDisplay()}
    }
    
    override func draw(_ rect: CGRect) {
        backgroundImage?.draw(in: bounds)
    }
}
