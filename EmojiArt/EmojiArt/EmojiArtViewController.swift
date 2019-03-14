//
//  EmojiArtViewController.swift
//  EmojiArt
//
//  Created by xu on 3/3/19.
//  Copyright © 2019 xu. All rights reserved.
//

import UIKit

class EmojiArtViewController: UIViewController,UIDropInteractionDelegate,UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    

    //MARK: - drop interaction for Drop View
    
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
    
    //MARK: - preferredDisplayMode setup
    //set the side view to be primaryOverlay
    //we are setting it in this method case everytime viewWillLayoutSubviews, preferredDisplayMode will be reset prossbiliy
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if  splitViewController?.preferredDisplayMode != .primaryOverlay {
            splitViewController?.preferredDisplayMode = .primaryOverlay
        }
  
    }
    
    
    //MARK: - scrollView setup
    
    var emojiArtView = EmojiArtView()
    
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
    
    //update the size of the scrollView
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollViewWidth.constant = scrollView.contentSize.width
        scrollViewHeight.constant = scrollView.contentSize.height
    }
    
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
            //update the size of the scrollView
            scrollViewWidth.constant = size.width
            scrollViewHeight.constant = size.height
        }
    }
    
    @IBOutlet weak var scrollViewWidth: NSLayoutConstraint!
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
   
    
    
    //MARK: - fetch data
    
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

    //MARK: - collection view
    
    var emojis = "🐱🐶🐭🐹🐰🐸🐣🐤🐝🐚🦋🦑🐙🦕🐳🐠🦈🦒".map{String($0)}
    
    @IBOutlet weak var emojiCollectionView: UICollectionView!{
        didSet{
            emojiCollectionView.dataSource = self
            emojiCollectionView.delegate = self
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojis.count
    }
    
    private var fontSize:CGFloat = 56
    
    private var font: UIFont {
        return UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.preferredFont(forTextStyle: .body)).withSize(fontSize)
    }
    
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionViewHeight.constant = fontSize * 1.6
        if collectionViewHeight.constant < 100.0 {
            collectionViewHeight.constant = 100.0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath)
        
        if let emojiCell = cell as? EmojiCollectionViewCell{
            let text = NSAttributedString(string: emojis[indexPath.row], attributes: [.font:font])
            emojiCell.emoji.attributedText = text
        }
        return cell
    }
    

}
