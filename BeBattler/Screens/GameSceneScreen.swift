
import SwiftUI
import SpriteKit

struct GameSceneScreen: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: ViewModel
  
    let scene: SKScene
 
    var body: some View {
        SpriteView(scene: scene)
            .ignoresSafeArea()
            .overlay(alignment: .topLeading) {
                DismissButton()
                
                if vm.showWinLoseView {
                    ZStack {
                        Color.gray.opacity(0.6)
                            .ignoresSafeArea()
                        
                        WinLoseView(status: vm.winOrLose) { action in
                            switch action {
                            case .home:
                                dismiss()
                            case .again:
                                vm.tryAgain()
                            case .next:
                                vm.getNextLevel()
                            }
                            vm.showWinLoseView = false
                        }
                    }
                }
            }
            .onAppear {
                vm.currentScene = scene
            }
    }
}






