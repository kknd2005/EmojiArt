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
    var thumbnail: UIImage? //store a snapshot for EmojiArtView, set from the controller when closing a document
    
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
    
    //override this method to write thumbnail to your document icon
    override func fileAttributesToWrite(to url: URL, for saveOperation: UIDocument.SaveOperation) throws -> [AnyHashable : Any] {
        var attributes = try? super.fileAttributesToWrite(to: url, for: saveOperation)
        if let thumbnail = self.thumbnail{
            attributes?[URLResourceKey.thumbnailDictionaryKey] =
                [URLThumbnailDictionaryItem.NSThumbnail1024x1024SizeKey:thumbnail]
        }
        return attributes!
    }
    
}
