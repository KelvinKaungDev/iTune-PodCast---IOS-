import Foundation
import UIKit

class MainTabController : UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tabBar.tintColor = .purple
        
        viewControllers = [
            TabBarController(with: SearchController(), title: "Search", image: UIImage(systemName:  "magnifyingglass")!),
            TabBarController(with: ViewController(), title: "Favourites", image: UIImage(systemName:  "heart")!),
            TabBarController(with: ViewController(), title: "Downloads", image: UIImage(systemName:  "chevron.down.circle")!)
        ]
        
    }
    
    fileprivate func TabBarController(with controller : UIViewController, title : String, image : UIImage) -> UIViewController {
        let navController = UINavigationController(rootViewController: controller)
        navController.navigationBar.prefersLargeTitles = true
        controller.navigationItem.title = title
        controller.tabBarItem.title = title
        controller.tabBarItem.image = image
        
        return navController
    }
    
}

