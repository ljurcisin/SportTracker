//
//  RootViewController.swift
//  Sports
//
//  Created by Lubomir Jurcisin on 06/04/2020.
//  Copyright © 2020 Lubomir Jurcisin. All rights reserved.
//

import UIKit

/**
 RootViewController manages two main app tab bars:
    - creating new activity and its setup walkthrough pages
    - history table view
*/
class RootViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let vc1 = UINavigationController(rootViewController: NewEntryPageViewController())
        let tabBar1 = UITabBarItem(title: NSLocalizedString("Create new", comment: ""), image: UIImage(named: "addIcon"), tag: 0)
        vc1.tabBarItem = tabBar1

        let vc2 =  ActivityRecordsTableViewController()
        let tabBar2 = UITabBarItem(tabBarSystemItem: .history, tag: 1)
        vc2.tabBarItem = tabBar2
        self.viewControllers = [vc1, vc2]
        self.selectedIndex = 1
    }
}
