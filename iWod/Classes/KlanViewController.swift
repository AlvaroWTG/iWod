//
//  KlanViewController.swift
//  iWod
//
//  Created by WebToGo on 6/2/17.
//  Copyright © 2017 Alvaro GMH. All rights reserved.
//

import UIKit

class KlanViewController: UIViewController, UIWebViewDelegate {
    
    //MARK: Properties
    
    /** Property that represents the progressView for the view */
    @IBOutlet weak var progressView: UIProgressView!
    /** Property that represents the webView for the view */
    @IBOutlet weak var webView: UIWebView!
    /** Property that represents the refresh timer */
    var timer: Timer!
    /** Property that represents the boolean whether is finished or not */
    var isFinished: Bool!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Setup navigation bar
        let navigationBar = navigationController?.navigationBar
        navigationBar?.barTintColor = Configuration.Color.ColorD93636
        UIApplication.shared.statusBarStyle = .lightContent
        navigationItem.title = "KLAN"

        let url = NSURL (string: "https://browod.com/booking")
        let requestObj = URLRequest.init(url: url! as URL)
        progressView.progressTintColor = Configuration.Color.ColorD93636
        progressView.progress = 0.0
        if webView.isLoading == false {
            webView.loadRequest(requestObj)
            webView.delegate = self
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: - Inherited functions from UIWebview delegate

    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return true
    }

    func webViewDidStartLoad(_ webView: UIWebView) {
        NSLog("[UIWebView] Log: Loading web view...")
        isFinished = false
        timer = Timer.scheduledTimer(timeInterval: 0.01667, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        NSLog("[UIWebView] Log: Web view loading finished...")
        self.isFinished = true
    }

    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        NSLog("[UIWebView] Error! Web view loading failed - Error 404 - \(error.localizedDescription)")
    }

    //MARK: - Auxiliary function

    /**
     * Auxiliary function that ticks the progress label
     */
    func tick() {
        if isFinished { // invalidate timer and hide the bar
            if progressView.progress >= 1 {
                progressView.isHidden = true
                timer.invalidate()
            } else {
                progressView.progress += 0.1
            }
        } else { // make progress
            progressView.progress += 0.05
            if progressView.progress >= 0.95 {
                progressView.progress = 0.95
            }
        }
    }
}
