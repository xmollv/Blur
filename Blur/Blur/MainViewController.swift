//
//  MainViewController.swift
//  Blur
//
//  Created by Xavi Moll on 01/01/2019.
//  Copyright © 2019 xmollv. All rights reserved.
//

import UIKit
import MobileCoreServices

class MainViewController: UIViewController {
    
    private lazy var plusButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.selectUserImage))
    }()
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let slider = UISlider(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Blur"
        self.view.backgroundColor = .black
        self.navigationItem.leftBarButtonItem = self.plusButton
        self.view.addSubview(self.imageView)
        NSLayoutConstraint.activate([
            self.imageView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            self.imageView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            self.imageView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            self.imageView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        
        self.setToolbarItems([UIBarButtonItem(customView: self.slider)], animated: false)
    }
    
    @objc
    private func selectUserImage() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        pickerController.allowsEditing = false
        pickerController.mediaTypes = [kUTTypeImage as String]
        self.present(pickerController, animated: true, completion: nil)
    }

}

extension MainViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { assertionFailure(); return }
        self.imageView.image = image
        self.dismiss(animated: true, completion: nil)
    }
}
