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
    }
    
    func updateUI(){
        
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
    
}
