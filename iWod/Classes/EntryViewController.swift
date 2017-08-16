//
//  EntryViewController.swift
//  iWod
//
//  Created by WebToGo on 8/16/17.
//  Copyright © 2017 Alvaro GMH. All rights reserved.
//

import UIKit

class EntryViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    //MARK: Properties

    @IBOutlet weak var textDescription: UITextView!

    @IBOutlet weak var labelDescription: UILabel!

    @IBOutlet weak var textField: UITextField!

    @IBOutlet weak var labelTitle: UILabel!

    var newEntry: Bool = false

    var row: Int = 0

    var descriptions = UserDefaults.standard.object(forKey: "wodDescriptions") as? NSMutableArray

    var titles = UserDefaults.standard.object(forKey: "wodTitles") as? NSMutableArray

    var dates = UserDefaults.standard.object(forKey: "wodDates") as? NSMutableArray

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        // Setup navigation bar
        let navigationBar = navigationController?.navigationBar
        navigationBar?.barTintColor = Configuration.Color.ColorD93636
        UIApplication.shared.statusBarStyle = .lightContent
        navigationBar?.isTranslucent = false

        // Setup the navigation item title
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel(_:)))
        if self.newEntry {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save(_:)))
            navigationItem.title = "New Entry"
        } else { // wod
            navigationItem.title = self.dates?[self.row] as? String
        }

        // Setup interface
        if self.newEntry { // new entry
            self.labelDescription.text = "Insert the description"
            self.labelTitle.text = "Insert a title for the WOD"
            self.textDescription.delegate = self
            self.textDescription.text = ""
            self.textField.delegate = self
        } else { // wod
            self.textDescription.text = self.descriptions?[self.row] as! String
            self.textField.text = self.titles?[self.row] as? String
            self.textDescription.isEditable = false
            self.labelDescription.isHidden = true
            self.labelTitle.isHidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Inherited functions from UITextView delegate
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return self.newEntry
    }

    //MARK: - IBAction implementation methods

    func cancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    func save(_ sender: UIButton) {
        self.textDescription.resignFirstResponder()
        let description = self.textDescription.text
        self.textField.resignFirstResponder()
        let title = self.textField.text
        let date = self.shareDate()
        if (title?.isEmpty)! {
            return
        }
        if (description?.isEmpty)! {
            return
        }
        if self.titles != nil {
            self.titles?.add(title ?? "")
        } else {
            self.titles = NSMutableArray.init(object: title ?? "")
        }
        if self.descriptions != nil {
            self.descriptions?.add(description ?? "")
        } else {
            self.descriptions = NSMutableArray.init(object: description ?? "")
        }
        if self.dates != nil {
            self.dates?.add(date)
        } else {
            self.dates = NSMutableArray.init(object: date)
        }
        UserDefaults.standard.set(self.descriptions, forKey: "wodDescriptions")
        UserDefaults.standard.set(self.titles, forKey: "wodTitles")
        UserDefaults.standard.set(self.dates, forKey: "wodDates")
        if UserDefaults.standard.synchronize() == true {
            self.dismiss(animated: true, completion: nil)
        }
    }

    //MARK: - Auxiliary method
    
    func shareDate() -> String {
        let formatter = DateFormatter.init()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: Date.init())
    }

}
