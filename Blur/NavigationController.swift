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
        self.navigationBar.barStyle = .blackTranslucent
        self.isToolbarHidden = false
        self.toolbar.barStyle = .blackTranslucent
    }
}
