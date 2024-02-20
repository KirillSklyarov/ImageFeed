//
//  WebviewViewControlle.swift
//  ImageFeedTests_sprint_13
//
//  Created by Kirill Sklyarov on 16.02.2024.
//

import Foundation
import ImageFeed

final class WebviewViewControllerSpy: WebViewControllerProtocol {
    var presenter: ImageFeed.WebViewPresenterProtocol?
    var loadRequestCalled: Bool = false
    
    func load(request: URLRequest) {
        loadRequestCalled = true
    }
    
    func setProgressValue(_ newValue: Float) {
    }
    
    func setProgressHidden(_ isHidden: Bool) {
    }
}
