//
//  EmojiArt.swift
//  EmojiArt
//
//  Created by bitone on 2019/3/20.
//  Copyright © 2019 xu. All rights reserved.
//

import Foundation

struct EmojiArt {
    
    var URL: URL
    var emojis = [EmojiInfo]()
    
    struct EmojiInfo {
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
