//
//  KlanViewController.swift
//  iWod
//
//  Created by WebToGo on 6/2/17.
//  Copyright © 2017 Alvaro GMH. All rights reserved.
//

import UIKit

class KlanViewCell: UITableViewCell {
    
    //MARK: Properties
    /** Property that represents the progressView for the view */
    @IBOutlet weak var labelTitle: UILabel!
    /** Property that represents the progressView for the view */
    @IBOutlet weak var labelDate: UILabel!

}

class KlanViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: Properties

    /** Property that represents the progressView for the view */
    @IBOutlet weak var tableView: UITableView!

    var titles = UserDefaults.standard.stringArray(forKey: "wodTitles")

    var dates = UserDefaults.standard.stringArray(forKey: "wodDates")

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        // Setup navigation bar
        let navigationBar = navigationController?.navigationBar
        navigationBar?.barTintColor = Configuration.Color.ColorD93636
        UIApplication.shared.statusBarStyle = .lightContent
        navigationBar?.isTranslucent = false

        // Setup the navigation item title
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didPress(_:)))
        navigationItem.title = "WODs"

        // Load information and setup table
        NotificationCenter.default.addObserver(self, selector: #selector(tableWillUpdate(_:)), name: NSNotification.Name(rawValue: "notificationTableWillUpdate"), object: nil)
        self.tableView.tableFooterView = UIView.init(frame: .zero)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: - Inherited functions from UITableview data source

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "KlanViewCell", for: indexPath) as! KlanViewCell
        cell.labelTitle.text = self.titles?[indexPath.row]
        cell.labelDate.text = self.dates?[indexPath.row]
        cell.labelDate.adjustsFontSizeToFitWidth = true
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.titles != nil {
            return self.titles!.count
        } else {
            return 0
        }
    }

    //MARK: - Inherited functions from UITableview delegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "EntryViewController") as! EntryViewController
        controller.newEntry = false
        controller.row = indexPath.row
        self.present(UINavigationController.init(rootViewController: controller), animated: true, completion: nil)
    }

    //MARK: - IBAction implementation methods

    @objc func didPress(_ sender: UIButton) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "EntryViewController") as! EntryViewController
        controller.newEntry = true
        self.present(UINavigationController.init(rootViewController: controller), animated: true, completion: nil)
    }

    //MARK: - Auxiliary method

    @objc func tableWillUpdate(_ notification: NSNotification) {
        self.titles = UserDefaults.standard.stringArray(forKey: "wodTitles")
        self.dates = UserDefaults.standard.stringArray(forKey: "wodDates")
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
