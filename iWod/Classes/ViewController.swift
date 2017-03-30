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

    @IBOutlet weak var buttonContinue: UIButton!
    @IBOutlet weak var buttonCancel: UIButton!
    @IBOutlet weak var imageWod: UIImageView!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelWod: UILabel!
    var dictionary:[String: Array<String>] = [:]
    var index = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // Setup interface
        dictionary = [:] as! [String : Array]
        DispatchQueue.global().async {self.fetch()}
        setupInterface()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: - IBAction implementation methods

    @IBAction func didPressRefresh(_ sender: UIButton) {
        index -= 1
        refresh()
    }

    @IBAction func didPressCancel(_ sender: UIButton) {
        index += 1
        refresh()
    }

    //MARK: - Auxiliary functions

    /**
     * Auxiliary function that downloads from an URL
     * - parameter url: The url string-value to download
     */
    func download(url: URL) {
        let data = try? Data.init(contentsOf: url)
        DispatchQueue.main.async { // Display wod image on imageView
            self.imageWod.image = UIImage(data:data!)
            self.imageWod.isHidden = data == nil
        }
    }

    /**
     * Auxiliary function that fetchs html content
     */
    func fetch() {
        var requestSession = Configuration.Workout.SessionRequest
        let year = Calendar.current.component(.year, from: Date())
        let month = Calendar.current.component(.month, from: Date())
        let stringMonth = month < 10 ? "/0\(month)" : "/\(month)"
        requestSession += "/\(year)\(stringMonth)"
        sendSynchronousRequest(requestSession: requestSession)
    }

    /**
     * Auxiliary function that gets the key for a row
     * - parameter row: The integer value of the row
     */
    func keyForRow(row: Int) -> String {
        let interval = TimeInterval(-24 * row * 60 * 60)
        let date = Date().addingTimeInterval(interval)
        let month = Calendar.current.component(.month, from: date)
        let monthBuilder = month < 10 ? "0\(month)" : "\(month)"
        let day = Calendar.current.component(.day, from: date)
        let keyDictionary = "17\(monthBuilder)\(day)"
        return keyDictionary
    }

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

    /**
     * Auxiliary function that parses the html looking for the image url
     * - parameter html: The html string-value to parse
     * - parameter key: The key to get string ranges
     */
    func parseImage(html: String, key: String) {
        var imagePath = Configuration.String.Empty
        var range = html.range(of: key)
        var div = html.substring(from: (range?.lowerBound)!)
        range = div.range(of: Configuration.Tag.TagDivEnd)
        div = div.substring(to: (range?.lowerBound)!)
        if let doc = HTML(html: div, encoding: .utf8) {
            for node in doc.css(Configuration.Tag.TagDivA) {
                var nodeRange = node.innerHTML?.range(of: Configuration.Tag.TagNodeSrc)
                if nodeRange != nil {
                    imagePath = (node.innerHTML?.substring(from: (nodeRange?.upperBound)!))!
                    nodeRange = imagePath.range(of: Configuration.Tag.TagNodeEnd)
                    imagePath = imagePath.substring(to: (nodeRange?.lowerBound)!)
                }
            }
        }

        // Download image and store last URL value to get it later
        download(url: URL.init(string: imagePath)!)
        UserDefaults.standard.set(imagePath, forKey: Configuration.Key.KeyLastUrl)
        UserDefaults.standard.synchronize()
    }

    /**
     * Auxiliary function that parses the html looking for the WOD
     * - parameter html: The html string-value to parse
     * - parameter key: The key to get string ranges
     */
    func parseWOD(html: String, key: String) {
        var wod = Configuration.String.Empty
        var range = html.range(of: key)
        var div = html.substring(from: (range?.lowerBound)!)
        range = div.range(of: Configuration.Tag.TagDivEnd)
        div = div.substring(to: (range?.lowerBound)!)
        if let doc = HTML(html: div, encoding: .utf8) {
            var valid = false
            for node in doc.css(Configuration.Tag.TagDivStart) {
                if valid {
                    wod = node.text!
                    break
                }
                valid = true
            }
        }
        DispatchQueue.main.async {self.labelWod.text = wod as String}
        UserDefaults.standard.set(Date(), forKey: Configuration.Key.KeyLastDate)
        UserDefaults.standard.set(wod, forKey: Configuration.Key.KeyLastWod)
        UserDefaults.standard.synchronize()
    /**
     * Auxiliary function that refreshes the interface
     */
    func refresh() {
        if let parameters = dictionary[keyForRow(row: index)] {
            download(url: URL.init(string: (parameters[0]))!)
            DispatchQueue.main.async {
                self.labelWod.text = parameters[1] as String
                self.buttonContinue.isEnabled = self.index > 0
                self.buttonCancel.isEnabled = self.index <= self.dictionary.count
            }
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
        buttonContinue.backgroundColor = Configuration.Color.ColorD93636
        buttonCancel.setTitleColor(Configuration.Color.ColorD93636, for: .normal)
        buttonContinue.setTitleColor(UIColor.white, for: .normal)
        buttonCancel.setTitle("PREVIOUS", for: .normal)
        buttonContinue.setTitle("NEXT", for: .normal)
        buttonContinue.isEnabled = false
        buttonCancel.isEnabled = true
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
                NSLog("[Alamofire] Log: Server response: \(response.result.description)")
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

