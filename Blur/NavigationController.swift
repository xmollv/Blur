//
//  NavigationController.swift
//  Blur
//
//  Created by Xavi Moll on 01/01/2019.
//  Copyright © 2019 xmollv. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let yellow = UIColor(displayP3Red: 255/255, green: 204/255, blue: 0, alpha: 1)
        self.navigationBar.barStyle = .blackTranslucent
        self.navigationBar.tintColor = yellow
        self.isToolbarHidden = false
        self.toolbar.barStyle = .blackTranslucent
        self.toolbar.tintColor = yellow
    }
}
