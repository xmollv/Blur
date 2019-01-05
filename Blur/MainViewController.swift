//
//  MainViewController.swift
//  Blur
//
//  Created by Xavi Moll on 01/01/2019.
//  Copyright © 2019 xmollv. All rights reserved.
//

import UIKit
import CoreImage
import MobileCoreServices

class MainViewController: UIViewController {
    
    //MARK: IBOutlets
    private lazy var plusButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.selectUserImage))
    }()
    private lazy var saveButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.saveResultingImage))
    }()
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    private lazy var slider: UISlider = {
        let slider = UISlider(frame: .zero)
        slider.addTarget(self, action: #selector(self.sliderValueChanged(_:)), for: .valueChanged)
        slider.minimumValue = 0.0
        slider.maximumValue = 100.0
        return slider
    }()
    
    //MARK: Private properties
    private var originalImage: UIImage?
    private var blurrer: Blurrer = _Blurrer()
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Blur"
        self.view.backgroundColor = .black
        self.navigationItem.leftBarButtonItem = self.plusButton
        self.navigationItem.rightBarButtonItem = self.saveButton
        self.view.addSubview(self.imageView)
        NSLayoutConstraint.activate([
            self.imageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.imageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.imageView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.imageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        self.setToolbarItems([UIBarButtonItem(customView: self.slider)], animated: false)
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(gestureReconizer:)))
        longPressGestureRecognizer.minimumPressDuration = 0.01
        self.imageView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    //MARK: IBActions
    @objc
    private func selectUserImage() {
        let pickerController = UIImagePickerController()
        pickerController.modalPresentationStyle = .popover
        pickerController.popoverPresentationController?.barButtonItem = self.plusButton
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        pickerController.allowsEditing = false
        pickerController.mediaTypes = [kUTTypeImage as String]
        self.present(pickerController, animated: true)
    }
    
    @objc
    private func sliderValueChanged(_ sender: UISlider) {
        guard let image = self.originalImage else {
            sender.setValue(0, animated: false)
            return
        }
        
        let formattedFloat = String(format: "%.0f", sender.value)
        self.title = "Blur - \(formattedFloat)%"
        
        self.imageView.image = self.blurrer.blur(image, amount: sender.value)
    }
    
    @objc
    private func saveResultingImage() {
        guard let image = self.imageView.image else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc
    private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            let ac = UIAlertController(title: "Save error", message: "\(error.localizedDescription). We need write access to your photos to save the image.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Settings", style: .default) { action in
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(url, options: [:])
            })
            ac.addAction(UIAlertAction(title: "Dismiss", style: .default))
            present(ac, animated: true)
        } else {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            let ac = UIAlertController(title: "Saved!", message: "Your image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Dismiss", style: .default))
            present(ac, animated: true)
        }
    }
    
    @objc
    private func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state != .ended {
            guard let image = self.originalImage else { return }
            self.imageView.image = image
        }
        else {
            self.sliderValueChanged(self.slider)
        }
    }

}

//MARK: UIImagePickerControllerDelegate
extension MainViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { assertionFailure(); return }
        self.originalImage = image
        self.sliderValueChanged(self.slider)
        self.dismiss(animated: true)
    }
}
