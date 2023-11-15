import Foundation
import UIKit

extension UIApplication {
    static func mainTabController() -> MainTabController {
        return shared.keyWindow?.rootViewController as! MainTabController
    }
}
