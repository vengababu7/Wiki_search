//
//  WikiDetailViewController.swift
//  WikiApp
//
//  Created by Maparthi Venga on 09/16/18.
//  Copyright © 2018 Maparthi Venga. All rights reserved.
//
import UIKit
import WebKit

class WikiDetailViewController: UIViewController {
    
    @IBOutlet weak var webViewOutlet: UIView!
    var webView : WKWebView!
    @IBOutlet weak var progressViewOutlet: UIProgressView!
    @IBOutlet weak var backButtonOutlet: UIButton!
    @IBOutlet weak var nextButtonOutlet: UIButton!
    
    struct Constant {
        static let defaultUrl = "https://en.wikipedia.org/wiki?curid="
        static let errorTitle = "Error"
        static let okayText = "Okay"
        static let estimatedProgress = "estimatedProgress"
        static let loading = "loading"
    }
    var pageTitle : String?
    var pageId : String?
    
    fileprivate func setupView() {
        self.title = pageTitle
        webView = WKWebView(frame: webViewOutlet.frame)
        webViewOutlet.addSubview(webView)
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        let height = NSLayoutConstraint(item: webView, attribute: .height, relatedBy: .equal, toItem: webViewOutlet, attribute: .height, multiplier: 1, constant: 0)
        let width = NSLayoutConstraint(item: webView, attribute: .width, relatedBy: .equal, toItem: webViewOutlet, attribute: .width, multiplier: 1, constant: 0)
        view.addConstraints([height, width])
        webView.addObserver(self, forKeyPath: Constant.loading, options: .new, context: nil)
        webView.addObserver(self, forKeyPath: Constant.estimatedProgress, options: .new, context: nil)
        if let url = self.getCurrentUrl() {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    private func getCurrentUrl() -> URL? {
        guard let pID = pageId else { return nil }
        let urlStr = Constant.defaultUrl + pID
        guard let url = URL(string: urlStr) else { return nil }
        return url
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
    }
    
    @IBAction func reloadButtonAction(_ sender: UIButton) {
        self.webView.reload()
    }
    
    @IBAction func safariButtonAction(_ sender: UIButton) {
        if let url = self.getCurrentUrl() {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.webView.goBack()
    }
    
    @IBAction func nextButtonAction(_ sender: UIButton) {
        self.webView.goForward()
    }
}


// MARK: - Progress view for webView
extension WikiDetailViewController  : WKNavigationDelegate {
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == Constant.loading) {
            backButtonOutlet.isEnabled = webView.canGoBack
            nextButtonOutlet.isEnabled = webView.canGoForward
        }
        if (keyPath == Constant.estimatedProgress) {
            progressViewOutlet.isHidden = webView.estimatedProgress == 1
            progressViewOutlet.setProgress(Float(webView.estimatedProgress), animated: true)
        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let alert = UIAlertController(title: Constant.errorTitle, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Constant.okayText, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressViewOutlet.setProgress(0.0, animated: false)
    }
}
