//
//  PhotoViewController.swift
//  mdimore
//
//  Created by Michael Dimore on 4/29/19.
//  Copyright © 2019 Michael Dimore. All rights reserved.
//

import UIKit
import AssetsLibrary

class PhotoViewController: UIViewController {
    
    var photoURL: String?
    
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var savePhotoBtn: UIButton!
    @IBOutlet weak var closePhotoBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadPhoto()
        let swipeClose = UISwipeGestureRecognizer(target: self, action: Selector(("didSwipePhoto")))
        swipeClose.direction = .down
        self.photoView.isUserInteractionEnabled = true
        self.photoView.addGestureRecognizer(swipeClose)
    }
    
    @objc func didSwipePhoto() {
        closeBtnPressed()
    }
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        let popupDialog = UIAlertController(title: "Save Image", message: "This image will be saved, Continue?", preferredStyle: .alert)
        popupDialog.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            guard let photo = self.photoView.image else { return }
            UIImageWriteToSavedPhotosAlbum(photo, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
        }))
        
        popupDialog.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(popupDialog, animated: true, completion: nil)
    }
    
    @IBAction func closeBtnPressed(_ sender: Any = []) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if (error == nil) {
            self.displayAlertMessage(title: "Success!", message: "Image save completed.")
        } else {
            self.displayAlertMessage(title: "ERROR!", message: (error?.localizedDescription)!)
        }
    }
    
    func displayAlertMessage(title: String, message: String) {
        let popupDialog = UIAlertController(title: title, message: message, preferredStyle: .alert)
        popupDialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(popupDialog, animated: true, completion: nil)
    }
    
    private func loadPhoto() {
        guard let photoURL = self.photoURL else { return }
        photoView.loadFrom(url: photoURL, animated: true)
    }
}

