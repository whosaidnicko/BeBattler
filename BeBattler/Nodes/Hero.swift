
import SpriteKit

protocol HeroProtocol: Identifiable {
    var id: Int { get }
    var name: String { get }
    var fireball: String { get }
    var cover: String { get }
    var pet: String { get }
    var isActive: Bool { get set }
   
}

struct Hero: HeroProtocol {
    let id: Int
    let name: String
    var cover: String {
        name + "_cover"
    }
    
    var fireball: String {
        name + "_fireball"
    }
    
    var pet: String {
        name + "_pet"
    }
    
    var isActive: Bool
}






