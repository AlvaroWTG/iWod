//
//  ViewController.swift
//  iWod
//
//  Created by WebToGo on 3/28/17.
//  Copyright © 2017 Alvaro GMH. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    //MARK: Properties

    @IBOutlet weak var buttonRefresh: UIButton!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelWod: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // Setup interface
        setupInterface()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: - IBAction implementation method

    @IBAction func didPressRefresh(_ sender: UIButton) {
        NSLog("Log: refreshing...")
    }

    //MARK: - Auxiliary functions

    /**
     * Auxiliary function that parse initial content
     */
    func parse(content: String) {
        let startString = "<h3 class=\"show\"><a href=\"/workout/2017/03/28\">"
        var range = content.range(of: startString)
        var stringBuilder = content.substring(from: (range?.lowerBound)!)
        let endString = "</div>"
        range = stringBuilder.range(of: endString)
        stringBuilder = stringBuilder.substring(to: (range?.lowerBound)!)
        DispatchQueue.main.async {self.labelWod.text = stringBuilder as String}
    }

    /**
     * Auxiliary function that setups the interface
     */
    func setupInterface() {

        // Setup navigation bar
        let navigationBar = navigationController?.navigationBar
        navigationBar?.barTintColor = Configuration.Colors.Color3B5996
        UIApplication.shared.statusBarStyle = .lightContent

        // Setup the navigation item title
        navigationItem.title = "iWOD"

        // Setup interface
        buttonRefresh.titleLabel?.text = "Refresh"
        labelDate.text = shareDate()
        labelWod.text = "Loading"

        // Send synch request
        sendSynchronousRequest(requestSession: "https://www.crossfit.com/workout/2017/03")
    }

    /**
     * Auxiliary function that shares the date
     */
    func shareDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: Date())
    }

    /**
     * Auxiliary function that obtains the reply to a request
     * @param requestSession The request session that needs a reply
     * @param isTest The boolean parameter to check whether there is a test
     */
    func sendSynchronousRequest(requestSession: String) {
        var request = URLRequest.init(url: URL.init(string: requestSession)!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        if #available(iOS 9.0, *) {
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                if let data = data, let result = String.init(data: data, encoding: String.Encoding.utf8) {
                    self.parse(content: result)
                } else if let error = error {
                    NSLog("[NSURLConnection] Error! Found an error. Error 500: %@", error.localizedDescription)
                }
            })
            task.resume()
        } else { // Fallback on earlier versions
            do {
                var response: URLResponse?
                let responseData = try NSURLConnection.sendSynchronousRequest(request, returning: &response)
                let result = String.init(data: responseData, encoding: String.Encoding.utf8)
                parse(content: result!)
            } catch let error as NSError {
                NSLog("[NSURLConnection] Error! Found an error. Error %d: %@", error.code, error.localizedDescription)
            }
        }
    }
}

