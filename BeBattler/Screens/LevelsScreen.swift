
import SwiftUI

struct LevelsScreen: View {
    @EnvironmentObject var vm: ViewModel
    
    let action: (any HeroProtocol) -> ()
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            HStack {
                Image(vm.myHero.cover)
                    .resizable()
                    .scaledToFit()
                    .padding(.vertical, 50)
                    .padding(.leading, 12)
                    .offset(y: 40)
                
                Text("VS")
                    .font(.custom(LocalFont.regular.rawValue, size: 72))
                    .foregroundStyle(LinearGradient(colors: [.yellowLight, .yellowDeep], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .shadow(color: .black, radius: 1, x: 2, y: 2)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(vm.allHeroes, id: \.id) { item in
                            Button {
                                guard item.isActive else { return }
                                action(item)
                            } label: {
                                Image(item.isActive ? item.cover : "locked")
                                    .resizable()
                                    .scaledToFit()
                                    .padding(.vertical, 42)
                            }
                            .buttonStyle(GameButtonStyle())
                        }
                    }
                }
                .frame(height: screen.height)
            }
        }
        .overlay(alignment: .topLeading) {
            DismissButton()
        }
    }
}

#Preview {
    LevelsScreen() {_ in }
        .environmentObject(ViewModel())
}
