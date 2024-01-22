import UIKit
import Kingfisher

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
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.DidChangeNotification,
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
        nameLabel.removeFromSuperview()
        nicknameLabel.removeFromSuperview()
        textLabel.removeFromSuperview()
    }
    
    private func updateProfileDetails(profile: Profile?) {
        guard let profile = profile else {
            print("Не смогли получить данные профиля")
            return }
        nameLabel.text = profile.loginName
        nicknameLabel.text = profile.userName
    }
    
    private func updateProfileImage() {
        guard let avatarURL = URL(string: profileImageService.avatarURL!) else { fatalError("Пришлa пустая ссылка на аватарку")}
        avatarImage.kf.setImage(with: avatarURL, placeholder: UIImage(named: "placeholder"))
    }
}
