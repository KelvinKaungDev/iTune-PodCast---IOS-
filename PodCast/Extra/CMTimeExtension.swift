import AVKit
import Foundation
extension CMTime {
    func toString() -> String {
        
        if CMTimeGetSeconds(self).isNaN {
            return "--:--:--"
        }
        
        let currentTime = Int(CMTimeGetSeconds(self))
        let second = currentTime % 60
        let minute = currentTime / 60
        let hour = currentTime / 3600
        
        return String(format: "%02d:%02d:%02d", hour, minute, second)
    }
}


