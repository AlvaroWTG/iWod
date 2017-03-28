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
        let date = Date()
        let lastWOD = UserDefaults.standard.string(forKey: "lastWOD")
        let oldDate = UserDefaults.standard.object(forKey: "lastDateWOD") as! Date
        let order = Calendar.current.compare(oldDate, to: date, toGranularity: .day)
        if lastWOD != nil && order == .orderedSame {
            DispatchQueue.main.async {self.labelWod.text = lastWOD}
        } else {
            var requestSession = Configuration.Workout.SessionRequest
            let year = Calendar.current.component(.year, from: date)
            let month = Calendar.current.component(.month, from: date)
            let stringMonth = month < 10 ? "/0\(month)" : "/\(month)"
            requestSession += "/\(year)\(stringMonth)"
            sendSynchronousRequest(requestSession: requestSession)
        }
    }

    //MARK: - Auxiliary functions

    /**
     * Auxiliary function that parse initial content
     */
    func parse(content: String) {
        let date = Date()
        var startString = Configuration.Workout.StartDayRange
        let year = Calendar.current.component(.year, from: date)
        let month = Calendar.current.component(.month, from: date)
        let stringMonth = month < 10 ? "/0\(month)" : "/\(month)"
        let day = Calendar.current.component(.day, from: date)
        startString += "/\(year)\(stringMonth)/\(day)"
        var range = content.range(of: startString)
        var stringBuilder = content.substring(from: (range?.lowerBound)!)
        range = stringBuilder.range(of: Configuration.Workout.EndDayRange)
        stringBuilder = stringBuilder.substring(to: (range?.lowerBound)!)
        range = stringBuilder.range(of: Configuration.Workout.StartWodRange)
        stringBuilder = stringBuilder.substring(from: (range?.upperBound)!)
        DispatchQueue.main.async {self.labelWod.text = stringBuilder as String}
        NSLog("[NSURLConnection] Log: Received server response %@", stringBuilder)
        UserDefaults.standard.set(stringBuilder, forKey: "lastWOD")
    }

    /**
     * Auxiliary function that setups the interface
     */
    func setupInterface() {

        // Setup navigation bar
        let navigationBar = navigationController?.navigationBar
        navigationBar?.barTintColor = Configuration.Colors.ColorD93636
        UIApplication.shared.statusBarStyle = .lightContent

        // Setup the navigation item title
        navigationItem.title = "iWOD"

        // Setup interface
        buttonRefresh.backgroundColor = Configuration.Colors.ColorD93636
        buttonRefresh.setTitleColor(UIColor.white, for: .normal)
        buttonRefresh.setTitle("WOD ME", for: .normal)
        labelWod.text = "Press button to receive WOD"
        labelDate.text = shareDate()
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
        NSLog("[NSURLConnection] Log: Sending synch request %@", requestSession)
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

