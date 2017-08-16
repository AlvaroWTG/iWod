//
//  EntryViewController.swift
//  iWod
//
//  Created by WebToGo on 8/16/17.
//  Copyright © 2017 Alvaro GMH. All rights reserved.
//

import UIKit

class EntryViewController: UIViewController {

    //MARK: Properties

    @IBOutlet weak var textDescription: UITextView!

    @IBOutlet weak var labelDescription: UILabel!

    @IBOutlet weak var textField: UITextField!

    @IBOutlet weak var labelTitle: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        // Setup navigation bar
        let navigationBar = navigationController?.navigationBar
        navigationBar?.barTintColor = Configuration.Color.ColorD93636
        UIApplication.shared.statusBarStyle = .lightContent
        navigationBar?.isTranslucent = false

        // Setup the navigation item title
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save(_:)))
        navigationItem.title = "New Entry"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: - IBAction implementation methods

    func save(_ sender: UIButton) {
        // Save information
    }

}
