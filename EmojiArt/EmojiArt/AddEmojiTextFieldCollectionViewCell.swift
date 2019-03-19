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
            emojiTextField.delegate = self
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emojiTextField.resignFirstResponder()
        return true
    }
}
