import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController {
    
    // MARK: - IB Outlets
    @IBOutlet weak var uiButton: UIButton!
    
    // MARK: - Public Properties
    weak var delegate: AuthViewControllerDelegate?
    
    lazy var authLogo: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "Vector-Auth")
        return image
    }()
    
    // MARK: - Private properties
    private let showWebViewSegueIdentifier = "ShowWebView"
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBackground
        view.addSubview(authLogo)
        authLogo.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            authLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            authLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            authLogo.widthAnchor.constraint(equalToConstant: 60),
            authLogo.heightAnchor.constraint(equalTo: authLogo.widthAnchor),
        ])
    }
    
    // MARK: - IB Actions
    @IBAction func buttonTapped(_ sender: Any) {
    }
}

// MARK: - Delegate
extension AuthViewController: WebViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        delegate?.authViewController(self, didAuthenticateWithCode: code)
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}

// MARK: - Navigation
extension AuthViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard let webViewViewController = segue.destination as? WebViewViewController
            else { fatalError("Failed to prepare for \(showWebViewSegueIdentifier)") }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}
