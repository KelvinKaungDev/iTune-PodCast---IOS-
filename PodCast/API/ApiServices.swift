import Alamofire
import Foundation
import FeedKit

class ApiServices {
    static let shared = ApiServices()
    
    func fetchEpisode(episodeUrl : String, completionHandler : @escaping (Episode) -> ()) {
        guard let url = URL(string: episodeUrl) else { return }
        DispatchQueue.global(qos: .background).async {
            let parser = FeedParser(URL: url)
            parser.parseAsync { (result) in
                switch result {
                case .success(let feed):
                    guard let safeFeed = feed.rssFeed else { return }
                    let imageUrl = safeFeed.iTunes?.iTunesImage?.attributes?.href ?? ""
                    safeFeed.items?.forEach({ (feedItem) in
                        var episode = Episode(feedItem: feedItem)
                        if episode.imageUrl == nil {
                            episode.imageUrl = imageUrl
                        }
                        completionHandler(episode)
                    })
                case .failure(_):
                    print("Error")
                }
            }
        }
    }
    
    func fetchData(with searchText : String, completionHandler : @escaping ([Results]) -> ()) {
        let url = "https://itunes.apple.com/search"
        let param = ["term" : searchText, "media" : "podcast"]
        AF.request(url, method: .get, parameters: param, encoding: URLEncoding.default, headers: nil).responseData { res in
            if res.error != nil {
                print("error")
            }
            
            guard let data = res.data else { return }
            do {
                let result = try JSONDecoder().decode(PodCast.self, from: data)
                completionHandler(result.results)
            } catch {
                print(error)
            }
        }
    }
}
