
import SpriteKit

final class Pet: SKSpriteNode {
    
    var startPosition: CGPoint = .zero

    static func getPet(_ hero: Hero) -> Pet {
        let pet = Pet(imageNamed: hero.pet)
        pet.name = hero.pet
        pet.zPosition = NodeZPosition.pet.rawValue
        pet.size = .init(width: 40, height: 40)
        return pet
    }
}
