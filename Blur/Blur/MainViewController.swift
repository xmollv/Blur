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
    private lazy var shareButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.shareResultingImage))
    }()
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private lazy var slider: UISlider = {
        let slider = UISlider(frame: .zero)
        slider.addTarget(self, action: #selector(self.sliderValueChanged(_:)), for: .valueChanged)
        return slider
    }()
    
    //MARK: Private properties
    private var _originalciImage: CIImage?
    private let context = CIContext()
    private let blurFilter = CIFilter(name: "CIGaussianBlur")
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Blur"
        self.view.backgroundColor = .black
        self.navigationItem.leftBarButtonItem = self.plusButton
        self.navigationItem.rightBarButtonItem = self.shareButton
        self.view.addSubview(self.imageView)
        NSLayoutConstraint.activate([
            self.imageView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            self.imageView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            self.imageView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            self.imageView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        
        self.setToolbarItems([UIBarButtonItem(customView: self.slider)], animated: false)
        
        
        let gr = UITapGestureRecognizer(target: self, action: #selector(self.resetSliderToDefault))
        gr.numberOfTapsRequired = 2
        self.slider.addGestureRecognizer(gr)
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
        guard let _ = self._originalciImage else {
            sender.setValue(0, animated: false)
            return
        }
        guard let blurFilter = self.blurFilter else { return }
        
        let formattedFloat = String(format: "%.0f", sender.value * 100)
        self.title = "Blur - \(formattedFloat)%"
        
        blurFilter.setValue(sender.value * 50, forKey: kCIInputRadiusKey)
        
        guard let outputImage = blurFilter.outputImage else { return }
        
        guard  let cgImage = self.context.createCGImage(outputImage, from: self._originalciImage?.extent ?? outputImage.extent) else { return }
        
        let processedImage = UIImage(cgImage: cgImage)
        self.imageView.image = processedImage
    }
    
    @objc
    private func shareResultingImage() {
        guard let image = self.imageView.image else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        activityViewController.modalPresentationStyle = .popover
        activityViewController.popoverPresentationController?.barButtonItem = self.shareButton
        activityViewController.excludedActivityTypes = [.addToReadingList, .assignToContact, .mail, .markupAsPDF, .openInIBooks, .postToFacebook, .postToFlickr, .postToTencentWeibo, .postToTwitter, .postToVimeo, .postToWeibo, .print]
        activityViewController.completionWithItemsHandler = { (activityType, completed, returnedItems, error) in
            guard completed, error == nil else {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                return
            }
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
        self.present(activityViewController, animated: true)
    }
    
    @objc
    private func resetSliderToDefault() {
        self.slider.setValue(0.35, animated: true)
        self.sliderValueChanged(self.slider)
    }

}

//MARK: UIImagePickerControllerDelegate
extension MainViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { assertionFailure(); return }
        
        self._originalciImage = CIImage(image: image)?.oriented(forExifOrientation: self.imageOrientationToTiffOrientation(image.imageOrientation))
        self.blurFilter?.setValue(self._originalciImage, forKey: kCIInputImageKey)
        
        self.slider.setValue(0.35, animated: true)
        self.sliderValueChanged(self.slider)
        
        self.dismiss(animated: true)
    }
}

extension MainViewController {
    func imageOrientationToTiffOrientation(_ value: UIImage.Orientation) -> Int32 {
        switch (value) {
        case .up:
            return 1
        case .down:
            return 3
        case .left:
            return 8
        case .right:
            return 6
        case .upMirrored:
            return 2
        case .downMirrored:
            return 4
        case .leftMirrored:
            return 5
        case .rightMirrored:
            return 7
        }
    }
}
