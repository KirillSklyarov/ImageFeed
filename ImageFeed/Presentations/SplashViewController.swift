import UIKit

final class SplashViewController: UIViewController {
    
    // MARK: - Private properties
    private let showAuthenticationScreenSegueIdentifier = "newsegue"
    private let oauth2Service = OAuth2Service.shared
    private let oauth2TokenStorage = OAuth2TokenStorage()
    
    // MARK: - View Life Cycles
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
                        
        if oauth2TokenStorage.token != nil {
            print("We have a token")
            switchToTabBarController()
        } else {
            print("We don't have a token")
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
}

// MARK: - Navigation
extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard let navigationController = segue.destination as? UINavigationController,
                  let viewController = navigationController.viewControllers[0] as? AuthViewController else {
                fatalError("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")
            }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

// MARK: - Delegate
extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        self.fetchOAuthToken(code)
    }
}

// MARK: - Private Methods
extension SplashViewController {
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: "TabBarViewController")
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
    
    private func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                print("Success")
                self.switchToTabBarController()
            case .failure:
                print("Error")
            }
        }
    }
}
