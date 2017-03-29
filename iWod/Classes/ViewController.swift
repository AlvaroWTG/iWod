//
//  ViewController.swift
//  iWod
//
//  Created by WebToGo on 3/28/17.
//  Copyright © 2017 Alvaro GMH. All rights reserved.
//

import UIKit
import Alamofire
import Kanna

class ViewController: UIViewController {

    //MARK: Properties

    @IBOutlet weak var buttonRefresh: UIButton!
    @IBOutlet weak var imageWod: UIImageView!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelWod: UILabel!
    var wods: [String: String] = [:]

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
     * - parameter html: The html string-value to parse
     */
    func parse(html: String) {

        // Setup string range for container
        let range = html.range(of: Configuration.Tag.TagContainer)
        let container = html.substring(from: (range?.lowerBound)!)

        // Setup calendar components for today
        let year = Calendar.current.component(.year, from: Date())
        let month = Calendar.current.component(.month, from: Date())
        let monthBuilder = month < 10 ? "/0\(month)" : "/\(month)"
        let day = Calendar.current.component(.day, from: Date())

        // Parse container for image
        var key = Configuration.Tag.TagContainerImage
        key += "/\(year)\(monthBuilder)/\(day)"
        parseImage(html: container, key: key)

        // Parse container for wod
        key = Configuration.Tag.TagContainerWod
        key += "/\(year)\(monthBuilder)/\(day)"
        parseWOD(html: container, key: key)
    }
    }

    /**
     * Auxiliary function that setups the interface
     */
    func setupInterface() {

        // Setup navigation bar
        let navigationBar = navigationController?.navigationBar
        navigationBar?.barTintColor = Configuration.Color.ColorD93636
        UIApplication.shared.statusBarStyle = .lightContent

        // Setup the navigation item title
        navigationItem.title = "iWOD"

        // Setup interface
        buttonRefresh.backgroundColor = Configuration.Color.ColorD93636
        buttonRefresh.setTitleColor(UIColor.white, for: .normal)
        buttonRefresh.setTitle("WOD ME", for: .normal)
        labelWod.text = "Press button to receive WOD"
        labelDate.text = shareDate()
        imageWod.isHidden = true
    }

    /**
     * Auxiliary function that shares the date
     * - returns: The current date formatted
     */
    func shareDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: Date())
    }

    /**
     * Auxiliary function that obtains the reply to a request
     * - parameter requestSession: The request session that needs a reply
     */
    func sendSynchronousRequest(requestSession: String) {
        NSLog("[Alamofire] Log: Sending request to %@", requestSession)
        var request = URLRequest.init(url: URL.init(string: requestSession)!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        if #available(iOS 9.0, *) {
            Alamofire.request(request).responseString { response in
                NSLog("[Alamofire] Log: Server response: \(response.result.isSuccess)")
                if let html = response.result.value {
                    self.parse(html: html)
                }
            }
        } else { // Fallback on earlier versions
            do {
                var response: URLResponse?
                let responseData = try NSURLConnection.sendSynchronousRequest(request, returning: &response)
                let html = String.init(data: responseData, encoding: String.Encoding.utf8)
                parse(html: html!)
            } catch let error as NSError {
                NSLog("[NSURLConnection] Error! Found an error. Error %d: %@", error.code, error.localizedDescription)
            }
        }
    }
}

