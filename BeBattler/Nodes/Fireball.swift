
import SpriteKit

final class Fireball: SKSpriteNode {
    static func getFireball(_ hero: Hero) -> Fireball {
        let fireball = Fireball(imageNamed: hero.fireball)
        fireball.zPosition = NodeZPosition.fireball.rawValue
        fireball.size = .init(width: 50, height: 50)
        return fireball
    }
}
