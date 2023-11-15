import Foundation
import UIKit

struct PodCast : Codable {
    var results : [Results]
}

struct Results : Codable {
    var artistName : String?
    var collectionName : String?
    var artworkUrl60 : String?
    var trackCount : Int?
    var feedUrl : String?
}
