
import SwiftUI

struct HomeScreen: View {
    @EnvironmentObject var vm: ViewModel
    
    @State private var showSettings = false
    @State private var showHeroes = false
    @State private var showLevels = false
    @State private var showGameScene = false
    
    var body: some View {
        
        HStack(alignment: .center) {
            Spacer()
            
            ButtonView(text: "My\nchampions", textSize: 22) {
                showHeroes = true
            }
            .frame(width: screen.height / 3)
            
            Spacer()
            
            ButtonView(text: "BATTLE", textSize: 42) {
                showLevels = true
            }
            .frame(width: screen.height / 2)
            
            Spacer()
            
            ButtonView(text: "Settings", textSize: 22) {
                showSettings = true
            }
            .frame(width: screen.height / 3)
            
            Spacer()
        }
        .popover(isPresented: $showSettings, arrowEdge: .bottom) {
            SettingsScreen()
        }
        .popover(isPresented: $showHeroes, arrowEdge: .bottom) {
            HeroesScreen(heroes: vm.allHeroes)
        }
        .popover(isPresented: $showLevels, arrowEdge: .bottom) {
            LevelsScreen() { enemy in
                vm.enemy = enemy
                showLevels = false
                showGameScene = true
            }
        }
        .fullScreenCover(isPresented: $showGameScene, content: {
            GameSceneScreen(scene: vm.getScene())
        })
    }
    
}

#Preview {
    HomeScreen()
        .environmentObject(ViewModel())
}

