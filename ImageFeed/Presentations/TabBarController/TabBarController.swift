import UIKit

final class TabBarController: UITabBarController {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let imageListViewController = storyboard.instantiateViewController(withIdentifier: "ImageListViewController")

        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(named: "active_1"),
            selectedImage: nil)
        
        self.viewControllers = [imageListViewController, profileViewController]
    }
}
