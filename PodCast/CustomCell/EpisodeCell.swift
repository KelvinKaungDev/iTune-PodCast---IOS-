import UIKit

class EpisodeCell: UITableViewCell {

    @IBOutlet var episodeImage: UIImageView!
    @IBOutlet var publicDate: UILabel!
    @IBOutlet var episodeTitle: UILabel!
    @IBOutlet var episodeDescription: UILabel!
    
    var Episode : Episode? {
        didSet {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            guard let url = URL(string: Episode?.imageUrl?.secureHttp() ?? "") else { return }
            
            publicDate.text = dateFormatter.string(from: Episode!.pubDate)
            episodeTitle.text = Episode?.title
            episodeDescription.text = Episode?.description
            episodeImage.sd_setImage(with: url)
        }
    }
}
