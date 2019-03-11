//
//  EmojiArtViewController.swift
//  EmojiArt
//
//  Created by xu on 3/3/19.
//  Copyright © 2019 xu. All rights reserved.
//

import UIKit

class EmojiArtViewController: UIViewController,UIDropInteractionDelegate,UIScrollViewDelegate {

    @IBOutlet var dropView: UIView!{
        didSet{dropView.addInteraction(UIDropInteraction(delegate: self))}
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSURL.self) && session.canLoadObjects(ofClass: UIImage.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    //var imageFetcher: ImageFetcher?
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {

//        imageFetcher = ImageFetcher(handler: { (url, image) in
//            DispatchQueue.main.async {
//                print(url)
//                self.emojiArtView.backgroundImage = image
//            }
//        })
        
        session.loadObjects(ofClass: NSURL.self) { urls in
            if let url = urls.first as? URL{
                //self.imageFetcher?.fetch(url: url)
                print(url)
                self.fetch(url: url, handler: { image in
                    DispatchQueue.main.async {
                        print("got image")
                        print(image)
                        self.emojiArtBackgroundImage = image
                    }
                })
            }
           
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView!{
        didSet{
            scrollView.delegate = self
            scrollView.minimumZoomScale = 0.1
            scrollView.maximumZoomScale = 5.0
            scrollView.addSubview(emojiArtView)
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return emojiArtView
    }
    
    var emojiArtView = EmojiArtView()
    
    var emojiArtBackgroundImage: UIImage?{
        get{
            return emojiArtView.backgroundImage
        }
        set{
            scrollView?.zoomScale = 1
            emojiArtView.backgroundImage = newValue
            let size = newValue?.size ?? CGSize.zero
            emojiArtView.frame = CGRect(origin: CGPoint.zero, size: size)
            scrollView?.contentSize = size
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    
    }
    
    func fetch(url:URL, handler:@escaping (UIImage)->Void){
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            
            if let data = try? Data(contentsOf: url){
                if self != nil{ //check if I am still in the heap?
                    if let image = UIImage(data: data){
                        handler(image)
                    }
                }else{
                    //igroning result case I'm not in the heap ever.
                }
            }
        }
    }


}
