
import AVKit

enum SoundType: String {
    case background, shoot, fire, win
}

final class SoundManager {
    static var shared: SoundManager = SoundManager()
    private var player: AVAudioPlayer?
    
    func playSound(_ type: SoundType) {
        if let url = Bundle.main.url(forResource: type.rawValue, withExtension: ".mp3") {
            player = try? AVAudioPlayer(contentsOf: url)
            if type == .background {
                player?.numberOfLoops = -1
                player?.volume = 0.3
            }
            player?.play()
        }
    }
    
    func getPlayerStatus() -> Bool? {
        return player?.isPlaying
    }
    
    func stopPlay() {
        guard let player, player.isPlaying == true else { return }
        return player.stop()
    }
}

