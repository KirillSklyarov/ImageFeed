import UIKit
import SwiftKeychainWrapper
import ProgressHUD

final class SplashViewController: UIViewController {
    
    // MARK: - Public Properties
    weak var authViewController: AuthViewController?
    
    // MARK: - Private properties
    private let oauth2Service = OAuth2Service.shared
    private let oauth2TokenStorage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    private let imageListService = ImageListService.shared
    
    private lazy var splashImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "vector")
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    // MARK: - View Life Cycles
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        view.backgroundColor = .ypBlack
        view.addSubview(splashImage)
        NSLayoutConstraint.activate([
            splashImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            splashImage.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        //        let authKey = "auth27"
        //        if !UserDefaults.standard.bool(forKey: authKey) {
        //            KeychainWrapper.standard.removeObject(forKey: "bearerToken")
        //            UserDefaults.standard.setValue(true, forKey: authKey)
        //        }
                
        if let token = oauth2TokenStorage.token {
            fetchProfile(token: token)
        } else {
            showAuthController()
        }
    }
}

// MARK: - Navigation
extension SplashViewController {
    func showAuthController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let vc = storyboard.instantiateViewController(withIdentifier: "AuthViewController")
        
        guard let vc = vc as? AuthViewController else {
            fatalError("Не могу создать AuthViewController")
        }
        authViewController = vc
        vc.delegate = self
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}

// MARK: - Delegate
extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        UIBlockingProgressHUD.dismiss()
        self.fetchOAuthToken(code)
    }
}

// MARK: - Private Methods
extension SplashViewController {
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first,
              let tabBarController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: "TabBarViewController") as? TabBarController else { fatalError("Invalid Configuration") }
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
    
    private func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success (let token):
                self.fetchProfile(token: token)
            case .failure:
                authViewController?.showAlert()
            }
        }
    }
    
    private func fetchProfile(token: String) {
        profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success (let profile):
                self.profileImageService.fetchProfileImageURL(
                    username: profile.userName,
                    token: token) {_ in }
                self.switchToTabBarController()
            case .failure:
                UIBlockingProgressHUD.dismiss()
                authViewController?.showAlert()
                break
            }
        }
    }
}
