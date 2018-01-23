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
import MessageUI
import UserNotifications

class ViewController: UIViewController, MFMailComposeViewControllerDelegate {

    //MARK: Properties

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
    /** Property that represents whether the notification is set or not */
    var isSet = false

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

    @objc func didPressRefresh(_ sender: UIButton) {
        if self.isSet == true {
            pushAlertView(message: "You have already setup a reminder")
        } else {
            let center = UNUserNotificationCenter.current()
            center.removeAllPendingNotificationRequests()
            let content = UNMutableNotificationContent()
            content.title = "It's Crossfit Time"
            content.body = "Time to book next week 7am class."
            content.sound = UNNotificationSound.default()
            content.badge = 1

            var referenceDate = DateComponents()
            referenceDate.hour = 00
            referenceDate.minute = 01
            referenceDate.second = 00

            let trigger = UNCalendarNotificationTrigger(dateMatching: referenceDate, repeats: true)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request) { (NSError) in
                if let error = NSError {
                    self.pushAlertView(message: "Error 404 -\(error.localizedDescription)")
                    self.isSet = false
                } else {
                    self.pushAlertView(message: "Notification request succesfully created")
                    self.isSet = true
                }
            }
        }
    }

    //MARK: - Gesture recognizer handler method

    @objc func didSwipe(gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case UISwipeGestureRecognizerDirection.right:
            index += 1
        case UISwipeGestureRecognizerDirection.left:
            index -= 1
        default:
            break
        }
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
     * Auxiliary function that pushes an alert view
     * - parameter message: The string value for the message
     */
    func pushAlertView(message: String) {
        let alert = UIAlertController(title: "KLAN", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    /**
     * Auxiliary function that pushes the safari view controller
     */
    func pushSafariViewController() {
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
        navigationBar?.isTranslucent = false

        // Setup the navigation item title
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didPressRefresh(_:)))
        navigationItem.title = "iWOD"

        // Setup interface
        labelDate.text = shareDate()
        labelWod.text = "Loading"
        imageWod.isHidden = true

        // Setup swipe gesture recognizers
        let swipePrevious = UISwipeGestureRecognizer(target: self, action: #selector(self.didSwipe(gesture:)))
        let swipeNext = UISwipeGestureRecognizer(target: self, action: #selector(self.didSwipe(gesture:)))
        swipePrevious.direction = .right
        swipeNext.direction = .left
        self.view.addGestureRecognizer(swipePrevious)
        self.view.addGestureRecognizer(swipeNext)
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

    //MARK: - PDF creator

    func createPDF() {
        let html = "<b>Hello <i>Cervi!</i></b> <p>Generated PDF file from HTML in Swift. Primera prueba creando un PDF desde una cadena de texto. A ver como sale</p>"
        let fmt = UIMarkupTextPrintFormatter(markupText: html)

        // 2. Assign print formatter to UIPrintPageRenderer
        let render = UIPrintPageRenderer()
        render.addPrintFormatter(fmt, startingAtPageAt: 0)

        // 3. Assign paperRect and printableRect
        let page = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4, 72 dpi
        let printable = page.insetBy(dx: 0, dy: 0)
        render.setValue(NSValue(cgRect: page), forKey: "paperRect")
        render.setValue(NSValue(cgRect: printable), forKey: "printableRect")

        // 4. Create PDF context and draw
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, CGRect.zero, nil)
        for i in 1...render.numberOfPages {
            UIGraphicsBeginPDFPage();
            let bounds = UIGraphicsGetPDFContextBounds()
            render.drawPage(at: i - 1, in: bounds)
        }
        UIGraphicsEndPDFContext();

        // 5. Save PDF file
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        pdfData.write(toFile: "\(documentsPath)/file-pdf.pdf", atomically: true)
    }

    func loadPDF() {
        createPDF()
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        mailComposerVC.setToRecipients(["a.gm.herrera@gmail.com", "carloscervera@hcmc.es"])
        mailComposerVC.setSubject("Enviando email desde app de Watito (prueba)...")
        mailComposerVC.setMessageBody("Este es el cuerpo de email, que ahora esta vacio!", isHTML: false)
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let filePath = "\(documentsPath)/file-pdf.pdf"
        let fileData = NSData(contentsOfFile: filePath)
        mailComposerVC.addAttachmentData(fileData! as Data, mimeType: "application/pdf", fileName: "file-pdf")
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposerVC, animated: true, completion: nil)
        } else {
            print("Mail services are not available")
            return
        }
    }

    // MARK: - MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

