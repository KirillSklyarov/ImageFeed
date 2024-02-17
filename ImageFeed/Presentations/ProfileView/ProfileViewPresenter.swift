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

//protocol ProfileViewPresenterProtocol {
//    func showAlert()
//}

final class ProfileViewPresenter {
    
    weak var viewController: ProfileViewController?
    
    func showAlert() {
        
        let alertController = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert)
        
        let quitAction = UIAlertAction(title: "Да", style: .default, handler: { _ in self.profileLogOut()
        })
        let cancelAction = UIAlertAction(title: "Нет", style: .cancel)
        
        alertController.addAction(quitAction)
        alertController.addAction(cancelAction)
        viewController?.present(alertController, animated: true)
    }
    
    
    func profileLogOut() {
        KeychainWrapper.standard.removeObject(forKey: "bearerToken")
        cleanCookies()
        switchToSplashViewController()
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func switchToSplashViewController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Can't present SplashViewController") }
        window.rootViewController = SplashViewController()
        window.makeKeyAndVisible()
    }
    
    func updateProfileDetails(profile: Profile?) {
        guard let profile = profile else {
            print("Не смогли получить данные профиля")
            return }
        viewController?.nameLabel.text = profile.name
        viewController?.nicknameLabel.text = profile.loginName
    }
    
    func updateProfileImage() {
        guard let imageURL = ProfileImageService.shared.avatarURL,
              let avatarURL = URL(string: imageURL) else {
            print("Пришлa пустая ссылка на аватарку")
            return
        }
        
        viewController?.avatarImage.kf.setImage(with: avatarURL, placeholder: UIImage(named: "placeholder"))
    }
}
