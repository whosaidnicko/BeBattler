
import SpriteKit


let userDefaults = UserDefaults.standard

// MARK: - SIZES

let screen = UIScreen.main.bounds.size
let sceneTransition = SKTransition.crossFade(withDuration: 0.4)

let boxSpacer = 40
let boxSize = 40
let yStep: [Int: Float] = [
    5: 0,
    4: 0.05,
    3: 0.1,
    2: 0.15
]

// MARK: zPosition

enum NodeZPosition: CGFloat {
    case background = 0
    case hero = 20
    case pet = 12
    case box = 10
    case overBox = 14
    case boxHighlight = 8
    case finish = 6
    case fireball = 18
    case fire = 16
}


