//
//  ViewController.swift
//  MemeApp
//
//  Created by Mahmoud Gamal El-Din on 4/2/20.
//  Copyright © 2020 MahmoudGamal. All rights reserved.
//

import UIKit

class ShareMemeViewController: UIViewController, UIImagePickerControllerDelegate , UITextFieldDelegate & UINavigationControllerDelegate {
    
    
    @IBOutlet weak var uiImageView : UIImageView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var navBar: UIToolbar!
    @IBOutlet weak var toolBar: UIToolbar!
    
    
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        .strokeColor: UIColor.black,
        .foregroundColor: UIColor.white,
        .font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        .strokeWidth: -4.0
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        shareButton.isEnabled = false
        
        setupTextField(topText)
        setupTextField(bottomText)
    }
    
    func setupTextField(_ textField: UITextField) {
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
        textField.textColor = UIColor.white
        textField.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    
    @objc func keyboardWillShow(_ notification:Notification){
        if bottomText.isFirstResponder {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    
    @objc func keyboardWillHide(_ notification:Notification){
        view.frame.origin.y = 0
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIWindow.keyboardWillShowNotification , object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func picImageFromAlbum(_sender: Any){
        openImagePicker(sourceType: .photoLibrary)
    }
    
    
    
    @IBAction func picImageFromCamera(_sender: Any){
        openImagePicker(sourceType: .camera)
    }
    
    func openImagePicker(sourceType:  UIImagePickerController.SourceType){
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.sourceType = sourceType
        present(controller,animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
        if let image = info[.originalImage] as? UIImage{
            uiImageView.image = image
            shareButton.isEnabled = true
        }
        
    }
    
    
    @IBAction func shareImage() {
        let memedImage = generateMemedImage()
        let activityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        // setting up dismissal of the activity view once the meme is successfully shared:
        activityViewController.completionWithItemsHandler = {
            (activity, success, items, error) in
            if (success) {
                self.saveMeme(memedImage)
                self.dismiss(animated: true, completion: nil)
            }
        }
        present(activityViewController, animated: true, completion: nil)
    }
    
    
    func saveMeme(_ image:UIImage){
        _ = Meme(topText: topText.text!, bottomText: bottomText.text!, originalImage: uiImageView.image!, memedImage: image)
    }
    func generateMemedImage() -> UIImage {
        // Render view to an image
        hideToolbars(true)
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        hideToolbars(false)
        
        return memedImage
    }
    
    func hideToolbars(_ hide: Bool){
        toolBar.isHidden = hide
        navBar.isHidden = hide
    }
    
}

