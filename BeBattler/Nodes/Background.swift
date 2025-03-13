
import UIKit
import SpriteKit

final class Background: SKSpriteNode {
    static func getBackground() -> Background {
        let background = Background(imageNamed: "background")
        background.setScale(0.8)
        background.zPosition = NodeZPosition.finish.rawValue
        return background
    }
}
