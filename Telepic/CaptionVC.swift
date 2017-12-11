//
//  CaptionVC.swift
//  Telepic
//
//  Created by Michael Bart on 11/13/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit
import AVKit

class CaptionVC: UIViewController, UITextViewDelegate {

    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var captionView: UIView!
    @IBOutlet weak var captionViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var previewImageTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var startAMovementSwitch: UISwitch!
    @IBOutlet weak var contestOfTheWeekSwitch: UISwitch!
    
    var image: UIImage?
    var videoURL: URL?
    var thumbnail: UIImage?
    var isGif = false
    
    var keyboardShowing = true
    var tapGestureRecognizer: UITapGestureRecognizer!
    
    let playButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "playButton")
        button.tintColor = .white
        button.isUserInteractionEnabled = false
        button.setImage(image, for: .normal)
        
        return button
    }()
    
    lazy var backBarButton: UIBarButtonItem = {
        let btn = UIButton(type: .system)
        btn.setImage(#imageLiteral(resourceName: "backArrowDark"), for: .normal)
        btn.height(40)
        btn.width(40)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        btn.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        return UIBarButtonItem(customView: btn)
    }()
    
    lazy var rightBarButton: UIBarButtonItem = {
        let btn = UIButton(type: .system)
        btn.setTitle("Forward", for: .normal)
        btn.sizeToFit()
        btn.addTarget(self, action: #selector(done), for: .touchUpInside)
        return UIBarButtonItem(customView: btn)
    }()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.navigationController?.navigationBar.isHidden = false
        
        previewImageView.clipsToBounds = true
        previewImageView.isUserInteractionEnabled = true
        navigationItem.leftBarButtonItem = backBarButton
        navigationItem.rightBarButtonItem = rightBarButton
        
        captionTextView.textContainerInset = UIEdgeInsets.zero
        captionTextView.contentInset = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        previewImageView.addGestureRecognizer(tapGesture)
        
        contestOfTheWeekSwitch.setOn(false, animated: false)
        
        if let image = image {
            self.previewImageView.image = image
        } else if let videoURL = videoURL, let thumbnail = thumbnail {
            self.previewImageView.image = thumbnail
            self.previewImageView.addSubview(playButton)
            playButton.centerVertically()
            playButton.centerHorizontally()
            playButton.height(30)
            playButton.width(30)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
    }
    
    @objc func imageTapped() {
        if videoURL != nil {
            self.presentVideoFullScreen()
        } else {
            self.goFullScreen()
        }
    }
    
    @IBAction func startAMovementSwitchValueChanged(_ sender: Any) {
    }
    
    func presentVideoFullScreen() {
        let playerViewController = AVPlayerViewController()
        playerViewController.player = AVPlayer(url: videoURL!)
        self.present(playerViewController, animated: true) {
            playerViewController.player?.play()
        }
    }
    
    func goFullScreen() {
        
    }
    
    @objc func goBack() {
        self.navigationController?.popViewController(animated: true)
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func done() {
        let sendVC = UIStoryboard(name: "Camera", bundle: nil).instantiateViewController(withIdentifier: Identifiers.sendVC) as! SendVC
        sendVC.caption = self.captionTextView.text == "Write a caption..." ? "" : self.captionTextView.text
        if let thumbnail = thumbnail { sendVC.data = UIImageJPEGRepresentation(thumbnail, 1.0)}
        if let image = image { sendVC.data = UIImageJPEGRepresentation(image, 1.0) }
        if let videoURL = videoURL, let thumbnail = thumbnail { sendVC.videoURL = videoURL; sendVC.data = UIImageJPEGRepresentation(thumbnail, 1.0) }
        self.navigationController?.pushViewController(sendVC, animated: true)
    }
    
    @objc func keyboardShow() {
        view.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc func keyboardHide() {
        view.removeGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func keyboardWillChangeFrame(_ notification: Notification) {
        let endFrame = ((notification as Notification).userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        if keyboardShowing {
//            captionViewTopConstraint.constant = -(view.bounds.height - endFrame.origin.y)
            previewImageTopConstraint.constant = -(view.bounds.height - endFrame.origin.y)
        } else {
//            captionViewTopConstraint.constant = 20
            previewImageTopConstraint.constant = 20
        }
        keyboardShowing = !keyboardShowing
        self.view.layoutIfNeeded()
    }
    
    @objc func tapGestureHandler() {
        view.endEditing(true)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("did begin editing")
        if textView.text == "Write a caption..." {
            textView.text = ""
            textView.textColor = UIColor(hexString: "333333")
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
//        if textView.text == "" {
//            textView.text = "Write a caption..."
//            textView.textColor = .lightGray
//        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Write a caption..."
            textView.textColor = .lightGray
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
