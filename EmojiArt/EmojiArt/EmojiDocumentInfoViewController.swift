//
//  EmojiDocumentInfoViewController.swift
//  EmojiArt
//
//  Created by bitone on 2019/3/27.
//  Copyright © 2019 xu. All rights reserved.
//

import UIKit

class EmojiDocumentInfoViewController: UIViewController {

    //MARK: - Model
    var document: EmojiArtDocument?{
        didSet{
            updateUI()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        updateUI()
        
        //don't need to do this
        //thumbnailView.image = thumbnailImage

    }
    
    //the way we configer date formatter
    private let shortDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()
    
    func updateUI(){
        //this method could be call when these labels aren't ready, so we need to check in advance
        if sizeLabel != nil, createdDate != nil{
            //try to get url and attributes of the document
            if let url = document?.fileURL,
                let attributes = try? FileManager.default.attributesOfItem(atPath: url.path){
                sizeLabel.text = "\(attributes[FileAttributeKey.size] ?? "unknown") bytes"
                //get date and convert to string
                if let created = attributes[.creationDate] as? Date{//this returns any, so don't forget to cast
                    createdDate.text = shortDateFormatter.string(from: created)
                }
                print("size and created date lables up to date")
            }
            
            //check if thumbnailView is ready, becase this could be called in prepare segue
            if thumbnailView != nil, let thumbnail = document?.thumbnail, thumbnailViewAspectRatio != nil{
                thumbnailView.image = thumbnail
                
                //remove old constraint
                thumbnailView.removeConstraint(thumbnailViewAspectRatio)
                
                //create a new constraint bease on thumbnail
                thumbnailViewAspectRatio = NSLayoutConstraint(
                    item: thumbnailView, //both item and toItem are thumbnailView, since we are setting up the aspect ratio of thumbnailview
                    attribute: .width,
                    relatedBy: .equal, // == multiplier below
                    toItem: thumbnailView,
                    attribute: .height,
                    multiplier: thumbnail.size.width / thumbnail.size.height, //this is the aspect radio of thumbnail
                    constant: 0)
                
                //add new constraint to thumbnailView
                thumbnailView.addConstraint(thumbnailViewAspectRatio)
                
            }
            
            //first time to see syntax like this.
            //Am I being presented as a Pop out?
            if presentationController is UIPopoverPresentationController{
                //hide thumbNail and button, set background color to clear
                //On iphone, this pop over view will be black becase the background is clear
                thumbnailView.isHidden = true
                returnButton.isHidden = true
                view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            }
        }
    }
    
    //MARK: - Perportys
    @IBAction func Done(_ sender: Any) {
        //we could've just put dismiss() here
        //but we use presentingViewController instead to remind us the relationship
        //Notice: it's presentingViewController, not presentedViewController or presentingController
        presentingViewController?.dismiss(animated: true)
    }
    
    
    //MARK: - Pop over size adpation
    
    //this method is called when all geometry is set
    //which is a good place for you to adjust any of them
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //get the smallest possible size that fits the view
        if let fittedSize = contentStackView?.sizeThatFits(UIView.layoutFittingCompressedSize){
            let gap : CGFloat = 30.0
            
            //setup content size of this view itself
            preferredContentSize = CGSize(width: fittedSize.width + gap , height: fittedSize.height + gap)
        }
    }
    

    @IBOutlet weak var returnButton: UIButton!
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var createdDate: UILabel!
    @IBOutlet weak var thumbnailView: UIImageView!
    var thumbnailImage: UIImage?
    @IBOutlet weak var thumbnailViewAspectRatio: NSLayoutConstraint!
}
