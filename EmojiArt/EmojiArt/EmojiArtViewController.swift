//
//  EmojiArtViewController.swift
//  EmojiArt
//
//  Created by xu on 3/3/19.
//  Copyright © 2019 xu. All rights reserved.
//

import UIKit

class EmojiArtViewController: UIViewController,UIDropInteractionDelegate,UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDragDelegate,UICollectionViewDropDelegate {


    

    

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
            //drag
            emojiCollectionView.dragDelegate = self
            //drop
            emojiCollectionView.dropDelegate = self
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
    
    //MARK: - collectionView drag
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        session.localContext = collectionView //let me know if the drag item is coming from collectionView(local context)
        return dragItems(at: indexPath)
    }
    
    //for muti-drag
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }
    
    private func dragItems(at indexPath: IndexPath) -> [UIDragItem]{
        if let attributString = (emojiCollectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell)?.emoji.attributedText {
            let dragItem = UIDragItem(itemProvider: NSItemProvider(object: attributString))
            dragItem.localObject = attributString
            return [dragItem]
        }else{
            return []
        }
    }

    //MARK: - collectionView drop
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSAttributedString.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        let isSelf = (session.localDragSession?.localContext as? UICollectionViewCell) == collectionView
        //different than View, becase collectionView needs to know how to add the dragItems into itself
        return UICollectionViewDropProposal(operation: isSelf ? .move : .copy, intent: .insertAtDestinationIndexPath)
    }
    
//    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
//        //1.get the destination
//        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
//
//        for item in coordinator.items{
//            //2.get the soruceIndex & dragData
//            if let sourceIndexPath = item.sourceIndexPath, let attributedString = item.dragItem.localObject as? NSAttributedString{
//                //3.must update those things in batch
//                collectionView.performBatchUpdates({
//                    emojis.remove(at: sourceIndexPath.item)
//                    emojis.insert(attributedString.string, at: destinationIndexPath.item)
//                    //Don't update the whole collectionView, del and insert sepratly
//                    collectionView.deleteItems(at: [sourceIndexPath])
//                    collectionView.insertItems(at: [destinationIndexPath])
//                })
//                //4.perform animation
//                coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
//            }
//        }
//    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        //1. get destationIndexPath
        let destationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        
        //2. go though every item
        for item in coordinator.items{
            //3. get soruceIndexPath
            //4. get the data from dragItem
            //the item is coming from inside this app
            if let soruceIndexPath = item.sourceIndexPath, let attributedString = item.dragItem.localObject as? NSAttributedString{
                collectionView.performBatchUpdates({
                    //5. update the model & UI
                    emojis.remove(at: soruceIndexPath.item)
                    emojis.insert(attributedString.string, at: destationIndexPath.item)
                    collectionView.deleteItems(at: [soruceIndexPath])
                    collectionView.insertItems(at: [destationIndexPath])
                })
                //6. perfrom animation
                coordinator.drop(item.dragItem, toItemAt: destationIndexPath)
            }else{
                //the item is coming from outside this app
                //1. create a placeHolder
                let placeHolder = coordinator.drop(item.dragItem,
                                                   to: UICollectionViewDropPlaceholder(insertionIndexPath: destationIndexPath, reuseIdentifier: "placeHolder"))
                
                //2. loadObject from dragItem
                item.dragItem.itemProvider.loadObject(ofClass: NSAttributedString.self) { (provider, error) in
                    //Note: this is excuting off the main queue!
                    DispatchQueue.main.async {
                        if let attributedString = provider as? NSAttributedString{
                            //3. tell placeHolder to update the model (commitInsection)
                            placeHolder.commitInsertion(dataSourceUpdates: { (IndexPath) in
                                self.emojis.insert(attributedString.string, at: IndexPath.item)
                            })
                        }else{
                            //4. if failed, delete placeHolder
                            placeHolder.deletePlaceholder()
                        }
                    }
                }
            }
        }

    }
}
