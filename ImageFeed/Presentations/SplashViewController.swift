import UIKit
import SwiftKeychainWrapper
import ProgressHUD

final class SplashViewController: UIViewController {
    
    // MARK: - Private properties
    private let oauth2Service = OAuth2Service.shared
    private let oauth2TokenStorage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    private lazy var splashImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "vector")
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    // MARK: - View Life Cycles
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        view.backgroundColor = .yellow
        view.addSubview(splashImage)
        NSLayoutConstraint.activate([
            splashImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            splashImage.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
//        KeychainWrapper.standard.removeObject(forKey: "bearerToken")
        
        if oauth2TokenStorage.token != nil {
            print("We have a token")
            self.fetchProfile(token: oauth2TokenStorage.token!)
            self.switchToTabBarController()
        } else {
            print("We don't have a token")
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
        vc.delegate = self
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}

// MARK: - Delegate
extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.fetchOAuthToken(code)
        }
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
                UIBlockingProgressHUD.dismiss()
            case .failure:
                self.showAlert()
                UIBlockingProgressHUD.dismiss()
            }
        }
    }
    
    private func fetchProfile(token: String) {
        profileService.fetchProfile(token) { [self] result in
//            guard let self = self else { return }
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success (let profile):
                ProfileImageService.shared.fetchProfileImageURL(username: profile.userName) { _ in }
                self.switchToTabBarController()
            case .failure:
                UIBlockingProgressHUD.dismiss()
                showAlert()
                break
            }
        }
    }
}

extension SplashViewController {
    
    func showAlert() {
        
        let alertController = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему",
            preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "ОК", style: .cancel)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
}
