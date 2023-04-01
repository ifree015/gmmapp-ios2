//
//  ViewController.swift
//  GmmApp
//
//  Created by GwangHyeok Yu on 2023/03/21.
//

import UIKit
import WebKit
import SnapKit

class ViewController: UIViewController {
    
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // 1. theme mode
        updateUserInterfaceStyle()
        // 2. init web view
        initWebView()
              
        // 3. webpage loading
        let urlReqeust = URLRequest(url: AppEnvironment.webRootUrl)
        webView.load(urlReqeust)
    }
    
    func initWebView() {
        // 1. configuration
        let webViewConfiguration = WKWebViewConfiguration()
        // javaScript 사용 설정
        webViewConfiguration.defaultWebpagePreferences.allowsContentJavaScript = true // WKWebpagePreferences
        // 자동으로 javaScript를 통해 새 창 열기 설정
        webViewConfiguration.preferences.javaScriptCanOpenWindowsAutomatically = true // WKPreferences
        
        // 2. javascript -> native
        webViewConfiguration.userContentController = JavascriptBridge.createWKUserContentController(messageHandler: self)
        
        
        // 4. webview 생성
        webView = WKWebView(frame: .zero, configuration: webViewConfiguration)
        self.view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.snp.makeConstraints { make in
            //$0.top.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.bottom.equalToSuperview()
        }
        //        let constraint: NSLayoutConstraint = webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
        //        constraint.isActive = true
        //        webView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.scrollView.showsHorizontalScrollIndicator = false
        //webView.scrollView.showsVerticalScrollIndicator = false
        webView.allowsBackForwardNavigationGestures = false
    }
}


extension ViewController: WKUIDelegate {
    
    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        
    }
    
    
}

extension ViewController: WKNavigationDelegate {
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else { return }
        debug("requestURL: \(url)")
        
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        debug("httpsHost: \(challenge.protectionSpace.host)")
#if DEBUG
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
#else
        completionHandler(.performDefaultHandling, nil)
#endif
    }
}
