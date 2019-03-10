//
//  ImageFetcher.swift
//  EmojiArt
//
//  Created by xu on 3/9/19.
//  Copyright © 2019 xu. All rights reserved.
//
import UIKit
import Foundation

class ImageFetcher{
    
    var handler:(URL,UIImage)->Void
    
    init(handler:@escaping (URL,UIImage)->Void) {
      self.handler = handler
    }
    
    func fetch(url:URL){
        DispatchQueue.global(qos: .userInitiated).async {[weak self] in
            if let data = try? Data.init(contentsOf: url){
                if self != nil{
                    //It's ok to create an UIImage off the main queue
                    if let image = UIImage.init(data: data){
                        self?.handler(url,image)
                    }else{
                        print("this data is not an image")
                    }
                    
                }else{
                    print("fetched data, but I've left the heap, ignoring  result")
                }
            }else{
                //fetch failed
                print("fetch failed: \(url)")
            }
        }
    }
}
