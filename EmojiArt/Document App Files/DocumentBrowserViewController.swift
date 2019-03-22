//
//  DocumentBrowserViewController.swift
//  EmojiArt
//
//  Created by xu on 3/3/19.
//  Copyright © 2019 xu. All rights reserved.
//

import UIKit


class DocumentBrowserViewController: UIDocumentBrowserViewController, UIDocumentBrowserViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        //allowsDocumentCreation = true
        allowsPickingMultipleItems = false
        
        //create a blank doc template
        newDocTemplate = try? FileManager.default.url(for: .applicationSupportDirectory,
                                             in: .userDomainMask,
                                             appropriateFor: nil,
                                             create: true).appendingPathComponent("untitled.json")
        
        if newDocTemplate != nil{ //if we got an URL, try to create a blank template
            //create a file, if successed, let user being able to create new document. if didn't, we won't allow user to create that.
            allowsDocumentCreation = FileManager.default.createFile(atPath: newDocTemplate!.path, contents: Data())
        }
        
        // Update the style of the UIDocumentBrowserViewController
        // browserUserInterfaceStyle = .dark
        // view.tintColor = .white
        
        // Specify the allowed content types of your application via the Info.plist.
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    //url for a blank emojiArtDocument template
    var newDocTemplate: URL?
    
    
    // MARK: UIDocumentBrowserViewControllerDelegate
    //ask for a blank document for documentCreation
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
        importHandler(newDocTemplate,.copy) //type in the argurments according @secaping(...)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentsAt documentURLs: [URL]) {
        guard let sourceURL = documentURLs.first else { return }
        
        // Present the Document View Controller for the first document that was picked.
        // If you support picking multiple items, make sure you handle them all.
        presentDocument(at: sourceURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) {
        // Present the Document View Controller for the new newly created document
        presentDocument(at: destinationURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, failedToImportDocumentAt documentURL: URL, error: Error?) {
        // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
    }
    
    // MARK: Document Presentation
    
    func presentDocument(at documentURL: URL) {
        
//        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
//        let documentViewController = storyBoard.instantiateViewController(withIdentifier: "DocumentViewController") as! DocumentViewController
//        documentViewController.document = Document(fileURL: documentURL)
//
      //  present(documentViewController, animated: true, completion: nil)
    }
}

