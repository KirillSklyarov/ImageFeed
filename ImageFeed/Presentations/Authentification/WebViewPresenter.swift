//
//  WebViewPresenter.swift
//  ImageFeed
//
//  Created by Kirill Sklyarov on 16.02.2024.
//

import Foundation

fileprivate let UnsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"

public protocol WebViewPresenterProtocol {
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL) -> String?
    
    var view: WebViewControllerProtocol? { get set }
}

final class WebViewPresenter: WebViewPresenterProtocol {
    
    weak var view: WebViewControllerProtocol?
    
    func viewDidLoad() {
        var urlComponents = URLComponents(string: UnsplashAuthorizeURLString)!
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        let url = urlComponents.url!
        let request = URLRequest(url: url)
        
        didUpdateProgressValue(0)
        
        view?.load(request: request)
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)
        
        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        view?.setProgressHidden(shouldHideProgress)
    }
    
    func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }
    
    func code(from url: URL) -> String? {
        if let urlComponents = URLComponents(string: url.absoluteString),
           urlComponents.path == "/oauth/authorize/native",
           let items = urlComponents.queryItems,
           let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
}

