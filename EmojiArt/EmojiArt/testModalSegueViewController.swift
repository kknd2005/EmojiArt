//
//  testModalSegueViewController.swift
//  EmojiArt
//
//  Created by bitone on 2019/3/26.
//  Copyright © 2019 xu. All rights reserved.
//

import UIKit

class testModalSegueViewController: UIViewController {

    //since we have a var points to the view that presents this view. e.g:presentationController
    //do we still need this?
    var parentVC : EmojiArtViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(presentationController as? EmojiArtViewController)
        print(parentVC)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func cancal(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
