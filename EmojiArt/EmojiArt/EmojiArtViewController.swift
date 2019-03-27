//
//  EmojiArtViewController.swift
//  EmojiArt
//
//  Created by xu on 3/3/19.
//  Copyright © 2019 xu. All rights reserved.
//

import UIKit

//extent EmojiArt.EmojiInfo here becase this is not a model thing, this is an UI thing
extension EmojiArt.EmojiInfo{
    
    //failable init
    init?(label: UILabel){
        if let attributedString = label.attributedText{
            x = Int(label.center.x)
            y = Int(label.center.y)
            text = attributedString.string
            size = 64//TODO: how to get font from attributedString?
        }else{
            return nil
        }

    }
}


class EmojiArtViewController: UIViewController,UIDropInteractionDelegate,UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDragDelegate,UICollectionViewDropDelegate , UICollectionViewDelegateFlowLayout{

    
    // MODIFIED AFTER LECTURE 14
    // we no longer need a save method or button
    // because now we are the EmojiArtView's delegate
    // (search for "delegate = self" below)
    // and we get notified when the EmojiArtView changes
    // (we also note when a new image is dropped, search "documentChanged" below)
    // and so we can just update our UIDocument's Model to match ours
    // and tell our UIDocument that it has changed
    // and it will autosave at the next opportune moment
    
    func documentChanged(){
        //tell the document to save
        emojiArtDocument?.emojiArt = emojiArt
        if emojiArt != nil{
            emojiArtDocument?.updateChangeCount(.done)
            print("auto saved successfully")
        }
    }

    //MARK: - model
    var emojiArt: EmojiArt?{
        //generate the model from background and labels in emojiArtView
        get{
            if let url = emojiArtBackgroundImage.url{
                //flatMap would return nil values(compactMap is the newVer of flatMap)
                //get [emojiInfo] from emojiArtView
                let emojis = emojiArtView.subviews.compactMap{$0 as? UILabel}.compactMap{EmojiArt.EmojiInfo(label: $0)}
                return EmojiArt(url: url, emojis: emojis)
            }
            return nil
        }
        //everytime we set the model, clean emojiArt and create the background and labels from the model
        set{
            //1. clean the EmojiArtView
            emojiArtBackgroundImage = (nil,nil) //remove background & URL
            emojiArtView.subviews.compactMap{$0 as? UILabel}.forEach{$0.removeFromSuperview()} //ask labels to remove themselves
            
            //2. fetch data
            if let url = newValue?.URL{
                fetch(url: url, handler: { image in
                    DispatchQueue.main.async {
                        //3. set emojiArtBackgroundImage
                        self.emojiArtBackgroundImage = (url,image)
                        //4. go thought every emojiInfo
                        newValue?.emojis.forEach {emojiInfo in
                            //5. ask emojiArtView to add label
                            self.emojiArtView.createLabel(with: emojiInfo)
                        }
                    }
                })
            }
        }
    }
    
    var emojiArtDocument: EmojiArtDocument?

    //the cookies for you to hold on to,
    //the only thing you do with those is to remove the observer when ViewWillDisappear or ViewDidDisappear
    var documentObserver: NSObjectProtocol?
    var emojiArtViewObserver: NSObjectProtocol?
    
    //load json from Document
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
         //for collectionView layout
        collectionViewHeight.constant = fontSize * 1.6
        if collectionViewHeight.constant < 100.0 {
            collectionViewHeight.constant = 100.0
        }
        
        //add observer to a Radio Station
        documentObserver = NotificationCenter.default.addObserver(
            forName: UIDocument.stateChangedNotification, //changed since iOS 11
            object: emojiArtDocument, //target
            queue: OperationQueue.main, //define which queue we are going to excute on
            using: { Notification in
                print("emojiArtDocument state changed")
        })
        
        //add emojiArtViewDidChange notfication
        emojiArtViewObserver = NotificationCenter.default.addObserver(
            forName: Notification.Name.EmojiArtViewDidChange,
            object: emojiArtView,
            queue: nil,
            using: { Notification in
                self.documentChanged()
                print("got music from emojiArtViewDidChange radio station")
        })
        
        //load from document
        //1. open the document
        emojiArtDocument?.open{success in
            if success{
                //2. get json from document
                self.title = self.emojiArtDocument?.localizedName
                self.emojiArt = self.emojiArtDocument?.emojiArt
            }
        }
        
    }
    

    //we don't need this since we have signed up delegate in emojiArtView
//    @IBAction func save(_ sender: UIBarButtonItem? = nil) { //nilable argurment :)
//            //tell the document to auto save
//            emojiArtDocument?.emojiArt = emojiArt
//            if emojiArt != nil{
//                emojiArtDocument?.updateChangeCount(.done)
//                print("saved successfully")
//            }
//    }
    
    @IBAction func close(_ sender: Any) {
        // MODIFIED AFTER LECTURE 14
        // the call to save() that used to be here has been removed
        // because we no longer explicitly save our document
        // we just mark that it has been changed
        // and since we are reliably doing that now
        // we don't need to try to save it when we close it
        // UIDocument will automatically autosave when we close()
        // if it has any unsaved changes
        // the rest of this method is unchanged from lecture 14
        
        //we don't save since we had made our model autosaved
        //save() //nilable argurment :)
        
        if emojiArt != nil{ //make sure the model != nil
            emojiArtDocument?.thumbnail = emojiArtView.snapshot //snapshot is made in an extention of UIView in Utilities.swift
        }
        presentingViewController?.dismiss(animated: true, completion: {
            self.emojiArtDocument?.close() //if you don't close the document, no change will be saved
            print("Document closed")
            
            //remove observer
            if let observer = self.emojiArtViewObserver{
                NotificationCenter.default.removeObserver(observer)
            }
            
            //remove observer
            if let observer = self.documentObserver{
                NotificationCenter.default.removeObserver(observer)
            }
        })
    }
    
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

//Modeifed for using UIAlertView
//                print(url)
//                self.fetch(url: url, handler: { image in
//                    DispatchQueue.main.async {
//                        print("got image")
//                        print(image)
//                        self.emojiArtBackgroundImage = (url,image)
//                    }
//                })
                
                
                //Added for UIAlertView
                DispatchQueue.global(qos:.userInitiated).async{
                    if let data = try? Data.init(contentsOf: url), let image = UIImage.init(data: data){
                        DispatchQueue.main.sync {
                            self.emojiArtBackgroundImage = (url,image)
                            self.documentChanged() //save after sucessfully droped image
                        }
                    }else{
                        self.presentBadURLWarning()
                    }
                }
            }
           
        }
    }
    
    private var suppressBadWarnning = false
    
    //If failed on loading image, show an alertView
    func presentBadURLWarning(){
        if !suppressBadWarnning{
            let alertView = UIAlertController(
                title: "Load image failed",
                message: "Couldn't drop image,\nDo you want to keep this warnning?",
                preferredStyle: .alert)
            
            alertView.addAction(UIAlertAction(
                title: "Keep Warnning Me",
                style: .default))
            
            alertView.addAction(UIAlertAction(
                title: "Stop Warnning Me",
                style: .destructive,
                handler: { (UIAlertAction) in
                    self.suppressBadWarnning = true
            }))
            
            present(alertView,animated: true)
        }
    }
    
    @IBOutlet weak var ImageFetchingActivityIndicator: UIActivityIndicatorView!
    
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
    
    // MODIFIED AFTER LECTURE 14
    // when we create our EmojiArtView, we also set ourself as its delegate
    // so that we can get emojiArtViewDidChange messages sent to us
    lazy var emojiArtView = EmojiArtView()
    
    @IBOutlet weak var scrollView: UIScrollView!{
        didSet{
            scrollView.delegate = self
            scrollView.minimumZoomScale = 0.1
            scrollView.maximumZoomScale = 5.0
            scrollView.addSubview(emojiArtView)
            emojiArtView.bounds = scrollView.bounds
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
    
    private var _emojiArtBackgroundImageURL: URL? //underbar implys that this is a background var setted by someone else
    
    //we want to keep these vars setted together
    var emojiArtBackgroundImage: (url:URL?,image:UIImage?){
        get{
            return (_emojiArtBackgroundImageURL,emojiArtView.backgroundImage)
        }
        set{
            _emojiArtBackgroundImageURL = newValue.url
            scrollView?.zoomScale = 1
            emojiArtView.backgroundImage = newValue.image
            let size = newValue.image?.size ?? CGSize.zero
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
        
        ImageFetchingActivityIndicator.startAnimating()
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            
            if let data = try? Data(contentsOf: url){
                if self != nil{ //check if I am still in the heap?
                    if let image = UIImage(data: data){// if the data is an image
                        handler(image) //call the handler
                    }
                    DispatchQueue.main.async {
                        self?.ImageFetchingActivityIndicator.stopAnimating()//stop indicator animation
                    }
                }else{
                    //igroning result case I'm not in the heap ever.
                }
                
            }
        }
    }

    //MARK: - adding emoji & text field
    @IBAction func addButtonPressed() {
        addingEmoji = true
        emojiCollectionView.reloadSections(IndexSet(integer: 0))
    }
    
    private var addingEmoji = false

    //MARK: - set size of textFieldCell (UICollectionViewDelegateFlowLayout)
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if addingEmoji && indexPath.section == 0{
            return CGSize(width: 300, height: 80)
        }else{
            return CGSize(width: 80, height: 80)
        }
    }
    
    //MARK: - becomeFirstResponder when textField shows up
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let inputCell = cell as? AddEmojiTextFieldCollectionViewCell{
            inputCell.emojiTextField.becomeFirstResponder()
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
            
            emojiCollectionView.dragInteractionEnabled = true //false by default on a n iPhone
        }
    }
    

    
    private var fontSize:CGFloat = 56
    
    private var font: UIFont {
        return UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.preferredFont(forTextStyle: .body)).withSize(fontSize)
    }
    
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    

    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section{
        case 0:
            return 1
        case 1:
            return emojis.count
        default:
            return 0
        }
        // return emojis.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 1{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath)
            
            if let emojiCell = cell as? EmojiCollectionViewCell{
                let text = NSAttributedString(string: emojis[indexPath.row], attributes: [.font:font])
                
                emojiCell.emoji.attributedText = text
            }
            return cell
        }else if addingEmoji{ //show TextFieldCell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "textField", for: indexPath)
            
            //setup the recall function in textField
            if let textFieldCell = cell as? AddEmojiTextFieldCollectionViewCell{
                textFieldCell.resginationHander = { [weak self, unowned textFieldCell] in //break the memory loop
                    //1. update emojis
                    if let text = textFieldCell.emojiTextField.text{
                        self?.emojis = text.map{String($0)} + self!.emojis //put new emojis at the front
                    }
                    
                    //2. update collectionView
                    self?.emojiCollectionView.reloadData()
                    
                    //3. set addingEmoji = false (let UI change back to add button)
                    self?.addingEmoji = false
                }
            }
            return cell
        }else{ //show Add button
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addButton", for: indexPath)
            return cell
        }

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
        //if trying to drop in the section of emojis
        if destinationIndexPath?.section == 1{
            let isSelf = (session.localDragSession?.localContext as? UICollectionViewCell) == collectionView
            //different than View, becase collectionView needs to know how to add the dragItems into itself
            return UICollectionViewDropProposal(operation: isSelf ? .move : .copy, intent: .insertAtDestinationIndexPath)
        }else{
            //if trying to drop in the add textField section, cancel the dropping action,or else it's gonna crash
            return UICollectionViewDropProposal(operation:.cancel)
        }
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
    
    // MARK: - modal segue

    
}
