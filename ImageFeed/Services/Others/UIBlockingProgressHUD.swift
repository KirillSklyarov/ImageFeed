import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    
   private static var window: UIWindow? {
        return UIApplication.shared.windows.first
    }
    
    static func show() {
        window?.isUserInteractionEnabled = false
        ProgressHUD.progress("Pictures are loading", 1.0)
        ProgressHUD.colorProgress = .ypRed
    }
    
    static func like() {
        window?.isUserInteractionEnabled = false
        ProgressHUD.progress("We're liking", 1.0)
    }
    
    static func dislike() {
        window?.isUserInteractionEnabled = false
        ProgressHUD.progress("We're disliking", 1.0)
    }
    
    
//    let progress = Float(receivedSize) / Float(totalSize)
//                    ProgressHUD.showProgress(progress)
    
    static func dismiss() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
}
