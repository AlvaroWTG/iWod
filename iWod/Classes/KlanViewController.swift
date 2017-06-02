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
    
    /** Property that represents the webView for the view */
    @IBOutlet weak var webView: UIWebView!

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
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        NSLog("[UIWebView] Log: Web view loading finished...")
    }

    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        NSLog("[UIWebView] Error! Web view loading failed - Error 404 - \(error.localizedDescription)")
    }
}
