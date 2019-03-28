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
        thumbnailView.image = thumbnailImage

    }
    
    func updateUI(){
        //this method could be call when these labels aren't ready, so we need to check in advance
        if sizeLabel != nil, createdDate != nil{
            //try to get url and attributes of the document
            if let url = document?.fileURL,
                let attributes = try? FileManager.default.attributesOfItem(atPath: url.path){
                sizeLabel.text = "\(attributes[FileAttributeKey.size] ?? "unknown") bytes"
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
    
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var createdDate: UILabel!
    @IBOutlet weak var thumbnailView: UIImageView!
    var thumbnailImage: UIImage?
}
