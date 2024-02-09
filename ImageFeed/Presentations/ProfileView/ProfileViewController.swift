import UIKit
import Kingfisher
import WebKit
import SwiftKeychainWrapper

final class ProfileViewController: UIViewController {
    
    // MARK: - Private properties
    private lazy var avatarImageSize = 70.0
    
    private lazy var avatarImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "Photo")
        image.tintColor = .gray
        image.layer.cornerRadius = avatarImageSize / 2
        image.clipsToBounds = true
        return image
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.textColor = .ypWhite
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        return label
    }()
    
    private lazy var nicknameLabel: UILabel = {
        let label = UILabel()
        label.text = "@ekaterina_nov"
        label.textColor = .ypGray
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        return label
    }()
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello, world!"
        label.textColor = .ypWhite
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        return label
    }()
    
    private lazy var exitButton: UIButton = {
        let buttonImage = UIImage(named: "Exit")
        guard let buttonImage = buttonImage else {return UIButton()}
        
        let button = UIButton.systemButton(with: buttonImage,
                                           target: self,
                                           action: #selector(buttonTapped(_ :)))
        button.tintColor = .ypRed
        return button
    }()
    
    var animationLayers = Set<CALayer>()
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypBackground
        
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.updateProfileImage()
        }
        
        updateProfileDetails(profile: profileService.profile)
        updateProfileImage()
        
        view.addSubview(avatarImage)
        view.addSubview(nameLabel)
        view.addSubview(exitButton)
        view.addSubview(nicknameLabel)
        view.addSubview(textLabel)
        
        avatarImage.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        nicknameLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            avatarImage.heightAnchor.constraint(equalToConstant: avatarImageSize),
            avatarImage.widthAnchor.constraint(equalTo: avatarImage.heightAnchor),
            avatarImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            nameLabel.leadingAnchor.constraint(equalTo: avatarImage.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: avatarImage.bottomAnchor, constant: 8),
            
            nicknameLabel.leadingAnchor.constraint(equalTo: avatarImage.leadingAnchor),
            nicknameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            
            textLabel.leadingAnchor.constraint(equalTo: avatarImage.leadingAnchor),
            textLabel.topAnchor.constraint(equalTo: nicknameLabel.bottomAnchor, constant: 8),
            
            exitButton.centerYAnchor.constraint(equalTo: avatarImage.centerYAnchor),
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    // MARK: - Private Methods
    @objc private func buttonTapped(_ sender: UIButton) {
        showAlert()
    }
    
    private func updateProfileDetails(profile: Profile?) {
        guard let profile = profile else {
            print("Не смогли получить данные профиля")
            return }
        nameLabel.text = profile.name
        nicknameLabel.text = profile.loginName
    }
    
    private func updateProfileImage() {
        guard let imageURL = profileImageService.avatarURL,
              let avatarURL = URL(string: imageURL) else { fatalError("Пришлa пустая ссылка на аватарку")}
        
        avatarImage.kf.setImage(with: avatarURL, placeholder: UIImage(named: "placeholder"))
    }
}

extension ProfileViewController {
    private func profileLogOut() {
        KeychainWrapper.standard.removeObject(forKey: "bearerToken")
        clearViewElements()
        cleanCookies()
        switchToSplashViewController()
    }
    
    private func clearViewElements() {
        nameLabel.removeFromSuperview()
        nicknameLabel.removeFromSuperview()
        textLabel.removeFromSuperview()
        avatarImage.removeFromSuperview()
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
}

extension ProfileViewController {
    private func showAlert() {
        let alertController = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert)
        
        let quitAction = UIAlertAction(title: "Да", style: .default, handler: { _ in self.profileLogOut()
        })
        let cancelAction = UIAlertAction(title: "Нет", style: .cancel)
        
        alertController.addAction(quitAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
}


//extension ProfileViewController {
//    func setGradient() {
//        let gradient = CAGradientLayer()
//        gradient.frame = CGRect(origin: .zero, size: CGSize(width: 70, height: 70))
//        gradient.locations = [0, 0.1, 0.3]
//        gradient.colors = [
//            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
//                UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
//                UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
//        ]
//        gradient.startPoint = CGPoint(x: 0, y: 0.5)
//        gradient.endPoint = CGPoint(x: 1, y: 0.5)
//        gradient.cornerRadius = 35
//        gradient.masksToBounds = true
////        animationLayers.append
//        avatarImage.layer.addSublayer(gradient)
//
//    }
//}
