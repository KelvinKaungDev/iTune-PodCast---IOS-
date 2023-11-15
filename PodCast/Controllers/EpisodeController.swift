import UIKit
import FeedKit

class EpisodeController : UITableViewController {
    
    var Episodes = [Episode]()
    
    var podCast : Results? {
        didSet {
            navigationItem.title = podCast?.collectionName
            fetchEpisode()
        }
    }
    
    fileprivate func fetchEpisode() {
        guard let feedUrl = podCast?.feedUrl?.secureHttp() else { return }
        ApiServices.shared.fetchEpisode(episodeUrl: feedUrl) { res in
            self.Episodes.append(res)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    static func episodeNib() -> EpisodeDetailCell {
       return Bundle.main.loadNibNamed("EpisodeDetailCell", owner: self)?.first as! EpisodeDetailCell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.definesPresentationContext = true
        
        let nib = UINib(nibName: "EpisodeCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: Custom.episodeCell)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Episodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Custom.episodeCell, for: indexPath) as! EpisodeCell
        let episode = self.Episodes[indexPath.row]
        cell.Episode = episode
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 132
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episode = Episodes[indexPath.row]
        let mainTabBarController = UIApplication.mainTabController()
        mainTabBarController.maxiDetailView(episode: episode)
        
//        add subview
////        let window = UIApplication.shared.connectedScenes.compactMap { ($0 as? UIWindowScene)?.keyWindow }.first
////        let playerDetailView = EpisodeController.episodeNib()
////        playerDetailView.episode = episode
////        playerDetailView.frame = self.view.frame
////        window?.addSubview(playerDetailView)
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        activityIndicator.color = .darkGray
        activityIndicator.startAnimating()
        return activityIndicator
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return Episodes.count > 0 ? 0 : 200
    }
}
