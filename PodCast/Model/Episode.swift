import Foundation
import FeedKit

struct Episode {
    var title : String?
    var pubDate : Date
    var description : String?
    var imageUrl : String?
    var aurthor : String?
    var streamUrl : String?
    
    init(feedItem : RSSFeedItem) {
        self.title = feedItem.title
        self.aurthor = feedItem.author ?? "Undefined"
        self.pubDate = feedItem.pubDate ?? Date()
        self.streamUrl = feedItem.enclosure?.attributes?.url
        self.description = feedItem.iTunes?.iTunesSubtitle ?? "Undefined"
        self.imageUrl = feedItem.iTunes?.iTunesImage?.attributes?.href ?? ""
    }
}
