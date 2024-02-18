import UIKit
import Kingfisher
import WebKit
import SwiftKeychainWrapper

protocol ProfileViewControllerProtocol: AnyObject {
    func updateAvatar()
    var presenter: ProfileViewPresenterProtocol? { get set }
}

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    
    // MARK: - Public properties
    var presenter: ProfileViewPresenterProtocol?
    
    // MARK: - Private properties
    private lazy var avatarImageSize = 70.0
    
    internal lazy var avatarImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "Photo")
        image.tintColor = .gray
        image.layer.cornerRadius = avatarImageSize / 2
        image.clipsToBounds = true
        return image
    }()
    
    internal lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.textColor = .ypWhite
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        return label
    }()
    
    internal lazy var nicknameLabel: UILabel = {
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
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure(presenter: ProfileViewPresenter())
        
        presenter?.addObserver()
        uiElementsSetup()
        updateProfileDetails(profile: profileService.profile)
        updateAvatar()
    }
    
    // MARK: - IB Actions
    @objc private func buttonTapped(_ sender: UIButton) {
        let alert = presenter?.showAlert()
        self.present(alert!, animated: true)
    }
    
    // MARK: - Private Methods
    private func updateProfileDetails(profile: Profile?) {
        if let profile = profile {
            nameLabel.text = profile.name
            nicknameLabel.text = profile.loginName
        } else {
            print("Не смогли получить данные профиля")
            return }
    }
    
    internal func updateAvatar() {
        let avatar = presenter?.updateProfileImage()
        self.avatarImage.kf.setImage(with: avatar, placeholder: UIImage(named: "placeholder"))
    }
    
    private func uiElementsSetup() {
        view.backgroundColor = .ypBackground
        
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
    
    private func configure(presenter: ProfileViewPresenterProtocol?) {
        self.presenter = presenter
        self.presenter?.viewController = self
    }
}
