import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    
   private static var window: UIWindow? {
        return UIApplication.shared.windows.first
    }
    
    static func show() {
        window?.isUserInteractionEnabled = false
        ProgressHUD.progress("Pictures are loading", 2.0)
        ProgressHUD.colorProgress = .ypRed
    }
    
    static func dismiss() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
}
