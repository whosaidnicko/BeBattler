
import SwiftUI

struct HeroesScreen: View {
    @EnvironmentObject var vm: ViewModel
    
    var allHroes: [any HeroProtocol]
    
    init(heroes: [any HeroProtocol]) {
        self.allHroes = heroes
        self.allHroes.insert(userHero, at: 0)
    }
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(allHroes, id: \.id) { item in
                        Button {
                            if item.isActive {
                                withAnimation {
                                    vm.myHero = item
                                }
                            }
                        } label: {
                            Image(item.isActive ? item.cover : "locked")
                                .resizable()
                                .scaledToFit()
                                .overlay(alignment: .topTrailing) {
                                    if item.name != vm.myHero.name && item.isActive != false {
                                        Color.gray.opacity(0.3)
                                    }
                                }
                                .padding(.vertical, 42)
                                .scaleEffect(item.name == vm.myHero.name ? 1 : 0.9 )
                        }
                        .buttonStyle(GameButtonStyle())
                    }
                }
            }
            .frame(height: screen.height)
            .padding(.leading, 12)
        }
        .overlay(alignment: .topLeading) {
            DismissButton()
        }
    }
}

#Preview {
    HeroesScreen(heroes: ViewModel().allHeroes)
        .environmentObject(ViewModel())
}
