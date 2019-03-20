//
//  AddEmojiTextFieldCollectionViewCell.swift
//  EmojiArt
//
//  Created by bitone on 2019/3/19.
//  Copyright © 2019 xu. All rights reserved.
//

import UIKit

class AddEmojiTextFieldCollectionViewCell: UICollectionViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var emojiTextField: UITextField!{
        didSet{
            //1. set the delegate right after declaration
            emojiTextField.delegate = self
        }
    }
    
    //2. resignFirstResponder() when return button pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emojiTextField.resignFirstResponder()
        return true
    }
    
    //3. declare a var of closure type for any one who's inteseted in getting textFieldDidEndEditing message
    var resginationHander: (()->Void)?
    
    //4. send the message
    func textFieldDidEndEditing(_ textField: UITextField) {
        resginationHander?()
    }
}
