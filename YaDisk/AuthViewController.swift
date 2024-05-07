//
//  AuthViewController.swift
//  YaDisk
//
//  Created by Алексей Решетников on 24.04.2024.
//

import UIKit
import WebKit

class AuthViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!

    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let url = URL(string: "https://oauth.yandex.ru/authorize?response_type=token&client_id=113b316964244161992260c0d5ea5e4b&redirect_uri=https://oauth.yandex.ru/verification_code") else {
            print("Invalid URL")
            return
        }
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, url.host == "oauth.yandex.ru" {
            // Попытка извлечь токен из фрагмента URL
            if let fragment = url.fragment {
                let params = fragment.components(separatedBy: "&").reduce(into: [String: String]()) { (result, part) in
                    let components = part.components(separatedBy: "=")
                    if components.count == 2 {
                        result[components[0]] = components[1]
                    }
                }
                if let token = params["access_token"] {
                    print("Токен: \(token)")
                    let diskModel = DiskModel()
                    diskModel.setToken(token)
                    decisionHandler(.cancel)
                    return
                }
            }
        }
        decisionHandler(.allow)
    }

}
