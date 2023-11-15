import UIKit
import SDWebImage
import AVKit
import MediaPlayer

class EpisodeDetailCell : UIView {
        
    var episode : Episode! {
        didSet {
            self.name.text = episode?.title
            self.miniLabel.text = episode?.title
            guard let url = URL(string: episode?.imageUrl?.secureHttp() ?? "") else { return }
            self.profile.sd_setImage(with: url)
            self.miniProfile.sd_setImage(with: url) { (image, _ ,_ , _) in
                guard let safeImage = image else { return }
                var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
                let artwork = MPMediaItemArtwork(boundsSize: safeImage.size, requestHandler: { (_) -> UIImage in
                    return safeImage
                })
                nowPlayingInfo?[MPMediaItemPropertyArtwork] = artwork
                MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
            }
            self.aurthor.text = episode?.aurthor ?? "Undefined"
            playAudio()
            audioLockScreenPlayingInfo()
        }
    }
    
    var panGesture : UIPanGestureRecognizer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setPlayerTime()
        remoteAudioControl()
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapMaxi)))
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        addGestureRecognizer(panGesture)
        maxiStackView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismissGesture)))
    }
    
    var player : AVPlayer = {
        let player = AVPlayer()
        player.automaticallyWaitsToMinimizeStalling = false
        return player
    }()
    
    @IBOutlet weak var dismiss: UIButton!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var profile: UIImageView! {
        didSet {
            profile.layer.cornerRadius = 5
            profile.clipsToBounds = true
            let scale = 0.7
            profile.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }

    @IBAction func playerVolume(_ sender: UISlider) {
        player.volume = sender.value
    }
    
    @IBAction func playBackward(_ sender: UIButton) {
        forwardAndBackward(inputValue: -15)
    }
    
    @IBAction func playForward(_ sender: UIButton) {
        forwardAndBackward(inputValue: 15)
    }
    @IBOutlet weak var showCurrentTimeBar: UISlider!
    
    @IBAction func handleCurrentPlayTime(_ sender: Any) {
        let currentTime = showCurrentTimeBar.value
        guard let duration = player.currentItem?.duration else { return }
        let seekTimeInSecond = Float64(currentTime) * CMTimeGetSeconds(duration)
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSecond, preferredTimescale: 1)
        player.seek(to: seekTime)
    }
    
    @IBOutlet weak var episodeCurrentTime: UILabel!
    @IBOutlet weak var episodeTotalPlayTime: UILabel!
    
    @IBOutlet weak var playAudioButton: UIButton! {
        didSet {
            playAudioButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            playAudioButton.addTarget(self, action: #selector(handleButton), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var aurthor: UILabel!
    
    @IBAction func dismiss(_ sender: UIButton) {
        let tabController = UIApplication.mainTabController()
        tabController.miniDetailView(episode: episode)
    }
    
    @IBOutlet weak var miniView: UIView!
    @IBOutlet weak var miniPlayerButton: UIButton! {
        didSet {
            miniPlayerButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
    }
    @IBOutlet weak var maxiView: UIStackView!
    @IBOutlet weak var miniProfile: UIImageView!
    @IBOutlet weak var miniLabel: UILabel!
    @IBOutlet weak var maxiStackView: UIStackView!
    
    @IBAction func miniHandlePause(_ sender: Any) {
        if player.timeControlStatus == .paused {
            player.play()
            miniPlayerButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            playAudioButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        } else {
            player.pause()
            miniPlayerButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            playAudioButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
    }
    
    @IBAction func miniPlayForward(_ sender: UIButton) {
        forwardAndBackward(inputValue: 15)
    }
    
    @objc func handleTapMaxi() {
        let tabController = UIApplication.mainTabController()
        tabController.maxiDetailView(episode: nil)
    }
    
    fileprivate func panChanged(_ gesture: UIPanGestureRecognizer) {
        let transform = gesture.translation(in: self.superview)
        self.transform = CGAffineTransform(translationX: 0, y: transform.y)
        self.miniView.alpha = 1 + transform.y / 200
        self.maxiStackView.alpha = -transform.y / 200
    }
    
    fileprivate func panEnded(_ gesture: UIPanGestureRecognizer) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.transform = .identity
            let transform = gesture.translation(in: self.superview)
            let velocity = gesture.velocity(in: self.superview)
            if transform.y < -200 || velocity.y < -500 {
                let mainTabBar = UIApplication.mainTabController()
                mainTabBar.maxiDetailView(episode: nil)
            } else {
                self.miniView.alpha = 1
                self.maxiView.alpha = 0
            }
        }
    }
    
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        if gesture.state == .changed {
            panChanged(gesture)
        } else if gesture.state == .ended {
            panEnded(gesture)
        }
    }
    
    @objc func handleDismissGesture(gesture: UIPanGestureRecognizer) {
        if gesture.state == .changed {
            let translation = gesture.translation(in: superview)
            maxiStackView.transform = CGAffineTransform(translationX: 0, y: translation.y)
        } else if gesture.state == .ended {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1) {
                let translation = gesture.translation(in: self.superview)
                self.maxiStackView.transform = .identity
                if translation.y > 50 {
                    let tabBarController = UIApplication.mainTabController()
                    tabBarController.miniDetailView(episode: nil)
                }
            }
        }
    }
    
    func playAudio() {
        guard let url = URL(string: (episode?.streamUrl?.secureHttp())!) else { return }
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }
    
    @objc func handleButton() {
        if player.timeControlStatus == .paused {
            player.play()
            playAudioButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            miniPlayerButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            shrinkProfileView()
        } else {
            player.pause()
            playAudioButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            miniPlayerButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            largeProfleView()
        }
    }

    fileprivate func largeProfleView() {
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.profile.transform = .identity
        }
    }
    
    fileprivate func shrinkProfileView() {
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut) {
            let scale = 0.7
            self.profile.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
    
    fileprivate func setPlayerTime() {
        let time = CMTime(value: 1, timescale: 2)
        self.player.addPeriodicTimeObserver(forInterval: time, queue: .main) { [weak self] time in
            self?.episodeCurrentTime.text = time.toString()
            let totalPlayTime = self?.player.currentItem?.duration
            self?.episodeTotalPlayTime.text = totalPlayTime?.toString()
            self?.setPlayerSlider()
        }
    }
    
    fileprivate func remoteAudioControl() {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        let remote = MPRemoteCommandCenter.shared()
        
        remote.playCommand.isEnabled = true
        remote.playCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.player.play()
            self.miniPlayerButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            self.playAudioButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            return .success
        }
        
        remote.pauseCommand.isEnabled = true
        remote.pauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.player.pause()
            self.playAudioButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            self.miniPlayerButton.setImage(UIImage(systemName: "pause .fill"), for: .normal)
            return .success
        }
        
        remote.togglePlayPauseCommand.isEnabled = true
        remote.togglePlayPauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.handleButton()
            return .success
        }
    }
    
    fileprivate func setPlayerSlider() {
        let currentTime = CMTimeGetSeconds(player.currentTime())
        let totalTime = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))
        self.showCurrentTimeBar.value = Float(currentTime / totalTime)
    }
    
    fileprivate func forwardAndBackward(inputValue : Int64) {
        let fifteenSec = CMTimeMake(value: inputValue, timescale: 1)
        let seekTime = CMTimeAdd(player.currentTime(), fifteenSec)
        player.seek(to: seekTime)
    }
    
    fileprivate func audioLockScreenPlayingInfo() {
        var playingInfo = [String : Any]()
        playingInfo[MPMediaItemPropertyTitle] = episode?.title
        playingInfo[MPMediaItemPropertyArtist] = episode?.aurthor
        MPNowPlayingInfoCenter.default().nowPlayingInfo = playingInfo
    }
    
}
