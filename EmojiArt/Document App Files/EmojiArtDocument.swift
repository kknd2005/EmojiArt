//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by bitone on 2019/3/22.
//  Copyright © 2019 xu. All rights reserved.
//

import UIKit

class EmojiArtDocument: UIDocument {

    var emojiArt: EmojiArt?
    
    override func contents(forType typeName: String) throws -> Any {
        // Encode your document with an instance of NSData or NSFileWrapper
        return emojiArt?.json ?? Data()
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        // Load your document from contents
        if let jsonData = contents as? Data{
            emojiArt = EmojiArt.init(json: jsonData)
        }
    }
}
