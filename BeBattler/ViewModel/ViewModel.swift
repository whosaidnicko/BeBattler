
import SwiftUI
import SpriteKit

final class ViewModel: ObservableObject {

    init() {
        maxLevelIndex = userDefaults.integer(forKey: "maxLevel")
        musicOn = userDefaults.object(forKey: "musicOn") == nil ? true : userDefaults.bool(forKey: "musicOn")
        soundOn = userDefaults.object(forKey: "soundOn") == nil ? true : userDefaults.bool(forKey: "soundOn")
        updateAllLevelsByMax()
    }
    
    @Published var musicOn: Bool = true
    {
        didSet {
            userDefaults.set(musicOn, forKey: "musicOn")
        }
    }
    @Published var soundOn: Bool = true
    {
        didSet {
            userDefaults.set(soundOn, forKey: "soundOn")
        }
    }
    
    @Published var allHeroes: [any HeroProtocol] = allHeroesArray
    @Published var myHero: any HeroProtocol = userHero
    @Published var enemy: any HeroProtocol = Hero(id: 0, name: "grizzly", isActive: true)
    
    @Published var winOrLose: WinOrLose = .win
    @Published var showWinLoseView = false

    var maxLevelIndex: Int = 0
    {
        didSet {
            userDefaults.set(maxLevelIndex, forKey: "maxLevel")
        }
    }
    
    var currentScene: SKScene?
    
    private func updateAllLevelsByMax() {
        for i in 0...maxLevelIndex {
            allHeroes[i].isActive = true
        }
    }
    
    func tryAgain() {
        showWinLoseView = false
        let newScene = GameScene(vm: self)
        newScene.scaleMode = .aspectFill
        currentScene?.view?.presentScene(newScene, transition: sceneTransition)
        currentScene = newScene
    }
    func nextLevelAvailable() {
        guard maxLevelIndex + 1 < allHeroes.count else {
            return
        }
        maxLevelIndex += 1
        updateAllLevelsByMax()
    }
    func getNextLevel() {
        guard enemy.id + 1 < allHeroes.count else {
            tryAgain()
            return
        }
        self.enemy = allHeroes[enemy.id + 1]
        let newScene = GameScene(vm: self)
        newScene.scaleMode = .aspectFill
        currentScene?.view?.presentScene(newScene, transition: sceneTransition)
        currentScene = newScene
    }
    func getScene() -> SKScene {
        let newScene = GameScene(vm: self)
        newScene.scaleMode = .aspectFill
        newScene.name = "init scene"
        if currentScene == nil {
            currentScene = newScene
        }
        return newScene
    }
}


