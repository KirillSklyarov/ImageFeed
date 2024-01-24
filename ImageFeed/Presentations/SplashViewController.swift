import UIKit
import SwiftKeychainWrapper
import ProgressHUD

final class SplashViewController: UIViewController {
    
    // MARK: - Private properties
    private let oauth2Service = OAuth2Service.shared
    private let oauth2TokenStorage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    weak var authViewController: AuthViewController?
    
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
        
        let authKey = "auth24"
        if !UserDefaults.standard.bool(forKey: authKey) {
            KeychainWrapper.standard.removeObject(forKey: "bearerToken")
            UserDefaults.standard.setValue(true, forKey: authKey)
        }
        
        if oauth2TokenStorage.token != nil {
            print("✅ Токен найден. Нужно только обновить данные из профиля и аватарку.")
            self.fetchProfile(token: oauth2TokenStorage.token!)
        } else {
            print("🔴 Токен не найден. Нужно пройти аутентификацию.")
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
    
    // В этом методе мы только делаем переход в зависиомости от результата обработки запроса
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
                    token: oauth2TokenStorage.token!) {_ in }
                self.switchToTabBarController()
            case .failure:
                UIBlockingProgressHUD.dismiss()
                authViewController?.showAlert()
                break
            }
        }
    }
}
