import Foundation
import UIKit

class MainTabController : UITabBarController {
    
    let playerView = EpisodeController.episodeNib()
    var miniEpisodeDetailView : NSLayoutConstraint!
    var maxiEpisodeDetailView : NSLayoutConstraint!
    var bottomDetailView : NSLayoutConstraint!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray
        tabBar.tintColor = .purple
        
        viewControllers = [
            TabBarController(with: SearchController(), title: "Search", image: UIImage(systemName:  "magnifyingglass")!),
            TabBarController(with: ViewController(), title: "Favourites", image: UIImage(systemName:  "heart")!),
            TabBarController(with: ViewController(), title: "Downloads", image: UIImage(systemName:  "chevron.down.circle")!)
        ]
        
        episodeDetailView()
    }
    
    func maxiDetailView(episode: Episode?) {
        maxiEpisodeDetailView.isActive = true
        miniEpisodeDetailView.isActive = false
        maxiEpisodeDetailView.constant = 0
        bottomDetailView.constant = 0
        
        if episode != nil {
            playerView.episode = episode
        }
    
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.view.layoutIfNeeded()
            self.tabBar.transform = CGAffineTransform(scaleX: 0, y: 100)
            self.playerView.miniView.alpha = 0
            self.playerView.maxiView.alpha = 1
        }
    }
    
    func miniDetailView(episode: Episode?) {
        miniEpisodeDetailView.isActive = true
        maxiEpisodeDetailView.isActive = false
        bottomDetailView.constant = view.frame.height

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.view.layoutIfNeeded()
            self.tabBar.transform = .identity
            self.playerView.miniView.alpha = 1
            self.playerView.maxiView.alpha = 0
        }
    }
    
    func episodeDetailView() {
        playerView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(playerView, belowSubview: tabBar)
        
        miniEpisodeDetailView = playerView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -64)
        miniEpisodeDetailView.isActive = false
        
        maxiEpisodeDetailView = playerView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height)
        maxiEpisodeDetailView.isActive = true
        
        bottomDetailView = playerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.frame.height)
        bottomDetailView.isActive = true
        
        NSLayoutConstraint.activate([
            playerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            playerView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
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

