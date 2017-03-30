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
    
    /** Property that represents the button for next wod */
    @IBOutlet weak var buttonContinue: UIButton!
    /** Property that represents the button for previous wod */
    @IBOutlet weak var buttonCancel: UIButton!
    /** Property that represents the image for the wod icon */
    @IBOutlet weak var imageWod: UIImageView!
    /** Property that represents the date of the wod */
    @IBOutlet weak var labelDate: UILabel!
    /** Property that represents the description of the wod */
    @IBOutlet weak var labelWod: UILabel!
    /** Property that represents the dictionary of links and wods */
    var dictionary:[String: Array<String>] = [:]
    /** Property that represents the index of the wod presented */
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

        // Navigate into the container
        var range = html.range(of: Configuration.Tag.TagContainer)
        let container = html.substring(from: (range?.upperBound)!)

        // Navigate into the container hybrid containing the rows
        range = container.range(of: Configuration.Tag.TagContainerHybrid)
        let containerHybrid = container.substring(from: (range?.upperBound)!)

        // Loop around the rows and get links and wods
        if let document = HTML(html: containerHybrid, encoding: .utf8) {
            let listImages = parseImage(html: document)
            let listWods = parseWOD(html: document)
            var i = 0
            for link in listImages {
                if i < listWods.count {
                    let keyDictionary = keyForRow(row: i)
                    dictionary[keyDictionary] = [link, listWods[i]]
                    i += 1
                }
            }
        }
        refresh()
    }

    /**
     * Auxiliary function that parses the html looking for the image url
     * - parameter html: The html string-value to parse
     */
    func parseImage(html: HTMLDocument) -> Array<String> {
        var result:Array<String> = []
        for node in html.css(Configuration.Tag.TagDivAImg) { // parse for image paths
            var nodeRange = node.innerHTML?.range(of: Configuration.Tag.TagNodeSrc)
            if nodeRange != nil {
                var imagePath = (node.innerHTML?.substring(from: (nodeRange?.upperBound)!))!
                nodeRange = imagePath.range(of: Configuration.Tag.TagNodeEnd)
                imagePath = imagePath.substring(to: (nodeRange?.lowerBound)!)
                result.append(imagePath)
            }
        }
        return result
    }

    /**
     * Auxiliary function that parses the html looking for the WOD
     * - parameter html: The html string-value to parse
     */
    func parseWOD(html: HTMLDocument) -> Array<String> {
        var result:Array<String> = []
        var wod = Configuration.String.Empty
        for node in html.css(Configuration.Tag.TagDivP) { // parse for wods
            if node.innerHTML?.range(of: Configuration.Tag.TagDivHref) == nil {
                if node.innerHTML?.range(of: Configuration.Tag.TagDivPost) == nil { // concatenate wod
                    wod = wod.isEmpty ? node.text! : wod + "\n\(node.text!)"
                } else {
                    result.append(wod)
                    wod = ""
                }
            }
        }
        return result
    }

    /**
     * Auxiliary function that refreshes the interface
     */
    func refresh() {
        if let parameters = dictionary[keyForRow(row: index)] {
            download(url: URL.init(string: (parameters[0]))!)
            DispatchQueue.main.async {
                self.labelDate.text = self.shareDate()
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
        imageWod.isHidden = true
    }

    /**
     * Auxiliary function that shares the date
     * - returns: The current date formatted
     */
    func shareDate() -> String {
        let interval = TimeInterval(-24 * index * 60 * 60)
        let date = Date().addingTimeInterval(interval)
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }

    /**
     * Auxiliary function that obtains the reply to a request
     * - parameter requestSession: The request session that needs a reply
     */
    func sendSynchronousRequest(requestSession: String) {
        NSLog("[Alamofire] Log: Sending request to %@", requestSession)
        var request = URLRequest.init(url: URL.init(string: requestSession)!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 10.0)
        request.httpMethod = Configuration.String.Get
        Alamofire.request(request).responseString { response in
            NSLog("[Alamofire] Log: Server response: \(response.result.description)")
            if let html = response.result.value {
                self.parse(html: html)
            }
        }
    }
}

