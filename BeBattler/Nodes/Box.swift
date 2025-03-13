
import SpriteKit

final class Box: SKSpriteNode {
    static func getBox(_ xScale: Bool) -> Box {
        let box = Box(imageNamed: "box")
        box.xScale = xScale ? 1 : -1
        box.size = .init(width: boxSize, height: boxSize)
        box.zPosition = NodeZPosition.box.rawValue
        return box
    }
}
