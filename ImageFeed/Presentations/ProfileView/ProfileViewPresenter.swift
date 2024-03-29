//
//  ProfileViewPresenter.swift
//  ImageFeed
//
//  Created by Kirill Sklyarov on 16.02.2024.
//

import Foundation
import UIKit
import SwiftKeychainWrapper
import WebKit

public protocol ProfileViewPresenterProtocol {
    func showAlert() -> UIAlertController
    func profileLogOut()
    func updateProfileImage() -> URL?
    func addObserver()
    
    var viewController: ProfileViewControllerProtocol? { get set }
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    
    // MARK: - Public properties
    weak var viewController: ProfileViewControllerProtocol?
    
    // MARK: - Public Methods
    func showAlert() -> UIAlertController {
        let alertController = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert)
        
        let quitAction = UIAlertAction(title: "Да", style: .default, handler: { _ in self.profileLogOut()
        })
        let cancelAction = UIAlertAction(title: "Нет", style: .cancel)
        
        alertController.addAction(quitAction)
        alertController.addAction(cancelAction)
        return alertController
    }
    
    func addObserver() {
        NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            _ = updateProfileImage()
        }
    }
    
    func updateProfileImage() -> URL? {
        if let imageURL = ProfileImageService.shared.avatarURL,
           let avatarURL = URL(string: imageURL) {
            return avatarURL
        } else {
            print("Пришлa пустая ссылка на аватарку")
            return nil
        }
    }
    
    func profileLogOut() {
        KeychainWrapper.standard.removeObject(forKey: "bearerToken")
        cleanCookies()
        switchToSplashViewController()
    }
    
    
    // MARK: - Private Methods
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func switchToSplashViewController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Can't present SplashViewController")
            return
        }
        window.rootViewController = SplashViewController()
        window.makeKeyAndVisible()
    }
}
