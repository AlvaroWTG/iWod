//
//  KlanViewController.swift
//  iWod
//
//  Created by WebToGo on 6/2/17.
//  Copyright © 2017 Alvaro GMH. All rights reserved.
//

import UIKit

class KlanViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Setup navigation bar
        let navigationBar = navigationController?.navigationBar
        navigationBar?.barTintColor = Configuration.Color.ColorD93636
        UIApplication.shared.statusBarStyle = .lightContent
        navigationItem.title = "KLAN"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
