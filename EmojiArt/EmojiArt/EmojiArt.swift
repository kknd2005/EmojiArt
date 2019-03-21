//
//  EmojiArt.swift
//  EmojiArt
//
//  Created by bitone on 2019/3/20.
//  Copyright © 2019 xu. All rights reserved.
//

import Foundation

//this is the model
struct EmojiArt: Codable { //make it codable so it could be complied to JSON
    
    var URL: URL
    var emojis = [EmojiInfo]()
    
    struct EmojiInfo: Codable { //caution! every var in this struct musk be codable!
        let x: Int
        let y: Int
        let text: String
        let size: Int
    }
    
    init(url: URL, emojis: [EmojiInfo]) {
        self.URL = url
        self.emojis = emojis
    }
}
