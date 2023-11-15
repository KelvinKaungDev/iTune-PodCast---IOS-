import UIKit
import Alamofire
import SDWebImage

class SearchController : UITableViewController, UISearchBarDelegate {
    
    var podCasts = [Results]()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.delegate = self
        self.definesPresentationContext = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PodCastCell")
        searchBar(searchController.searchBar, textDidChange: "Messi")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
            ApiServices.shared.fetchData(with: searchText) { res in
                self.podCasts = res
                self.tableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let indicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        indicatorView.color = .darkGray
        indicatorView.startAnimating()
        return indicatorView
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return podCasts.count > 0 ? 0 : 200
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podCasts.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episodeController = EpisodeController()
        episodeController.podCast = podCasts[indexPath.row]
        navigationController?.pushViewController(episodeController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PodCastCell", for: indexPath)
        let podcast = podCasts[indexPath.row]
        cell.textLabel?.text = "\(podcast.collectionName ?? Custom.undefined)\n\(podcast.artistName ?? Custom.undefined)\n\(podcast.trackCount ?? 0) Episodes"
        cell.textLabel?.numberOfLines = -1
        if let safeUrl = URL(string: podcast.artworkUrl60 ?? Custom.defaultImage) {
            cell.imageView?.sd_setImage(with: safeUrl, completed: nil)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 132
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "Please Enter a Search Term"
        label.textAlignment = .center
        label.textColor = .purple
        label.font = label.font.withSize(18)
        return label
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return podCasts.count > 0 ? 0 : 250
    }
}
