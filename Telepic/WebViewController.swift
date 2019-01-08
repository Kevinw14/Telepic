//
//  WebViewController.swift
//  Telepic
//
//  Created by Kevin Wood on 11/6/18.
//  Copyright © 2018 Telepic LLC. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {
    
    private let webView: WKWebView
    
    
    init(url: URL) {
        webView = WKWebView(frame: UIScreen.main.bounds)
        let request = URLRequest(url: url)
        webView.load(request)
        super .init(nibName: nil, bundle: nil)
        self.view.addSubview(webView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
