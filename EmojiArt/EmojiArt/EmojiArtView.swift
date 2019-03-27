//
//  EmojiArtView.swift
//  EmojiArt
//
//  Created by xu on 3/3/19.
//  Copyright © 2019 xu. All rights reserved.
//

import UIKit

// ADDED AFTER LECTURE 14
// this is the delegate protocol for EmojiArtView
// EmojiArtView wants to be able to let people
// (usually its Controller)
// know when its contents have changed
// but MVC does not allow it to have a pointer to its Controller
// it must communicate "blind and structured"
// this is the "structure" for such communication
// see the delegate var in EmojiArtView below
// note that this protocol can only be implemented by a class
// (not a struct or enum)
// that's because the var with this type is going to be weak
// (to avoid memory cycles)
// and weak implies it's in the heap
// and that implies its a reference type (i.e. a class)
protocol EmojiArtViewDelegate: class {
    func emojiArtViewDidChange(_ sender:EmojiArtView)
}

//add radio station 01: add new name
extension Notification.Name{
    static let EmojiArtViewDidChange = Notification.Name(rawValue: "EmojiArtViewDidChange")
}


class EmojiArtView: UIView , UIDropInteractionDelegate{

    // MARK: - Delegation
    
    // ADDED AFTER LECTURE 14
    // if a Controller wants to find out when things change
    // in this EmojiArtView
    // the Controller has to sign up to be the EmojiArtView's delegate
    // then it can have methods in that protocol invoked on it
    // this delegate is notified every time something changes
    // (see uses of this delegate var below and in EmojiArtView+Gestures.swift)
    // this var is weak so that it does not create a memory cycle
    // (i.e. the Controller points to its View and its View points back)
    
    weak var delegate: EmojiArtViewDelegate?
    
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
                //4. send message to anyone that has signed up my delegation
                self.delegate?.emojiArtViewDidChange(self) //still hold onto this, tough we don't use it anymore
                //post on radio station
                NotificationCenter.default.post(name: Notification.Name.EmojiArtViewDidChange, object: self)

            }
        }
    }
    
    //called by controller to create labels from model
    func createLabel(with emojiInfo: EmojiArt.EmojiInfo){
        let attributedString = emojiInfo.text.attributedString(withTextStyle: .body, ofSize: CGFloat(emojiInfo.size))
        createLabel(withAttributedString: attributedString, at: CGPoint(x: emojiInfo.x, y: emojiInfo.y))
    }
    
    //we don't need to remove kvo when viewWillDisappear
    //KVO will be removed from heap when emojiArtView disappear automaticly
    //but what if we remove a label?
    //we keep KVOs in a dict based on UIView(label)
    //so that we can remove KVO when a label is going to be remove
    private var KVO = [UIView:NSKeyValueObservation]()
    
    //add new emoji to emojiArtView
    func createLabel(withAttributedString string:NSAttributedString, at centered:CGPoint){
        let newLabel = UILabel()
        newLabel.attributedText = string
        newLabel.sizeToFit()
        newLabel.center = centered
        addEmojiArtGestureRecongizers(to: newLabel)
        addSubview(newLabel)
        KVO[newLabel] = newLabel.observe(\.center, changeHandler: { (label, change) in
            //nobody signed up this delegate for now, but we still keep this line of code
            self.delegate?.emojiArtViewDidChange(self)
            //boardcast on radio station
            NotificationCenter.default.post(name: Notification.Name.EmojiArtViewDidChange, object: self)
        })
    }

    //when a label(subview) will be removed
    //we check if this is a KVO needs to be removed as well
    override func willRemoveSubview(_ subview: UIView) {
        super.willRemoveSubview(subview)
        
        if KVO[subview] != nil{
            KVO[subview] = nil
        }
    }
    
    //MARK: - backgroundImage
    var backgroundImage: UIImage?{
        didSet{setNeedsDisplay()}
    }
    
    override func draw(_ rect: CGRect) {
        backgroundImage?.draw(in: bounds)
    }
}
