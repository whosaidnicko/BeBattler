
import SwiftUI

enum ActionType {
    case home, again, next
}

enum WinOrLose {
    case win, lose
}

struct WinLoseView: View {
    @EnvironmentObject var vm: ViewModel
    let status: WinOrLose
    let action: (ActionType)->()
    
    var body: some View {
        VStack {
            Text(status == .win ? "You Win" : "You Lose")
                .font(.custom(LocalFont.regular.rawValue, size: 32))
                .foregroundStyle(.white)
                .shadow(color: .black, radius: 1, x: 2, y: 2)
            
            HStack {
                Group {
                    ButtonView(text: "Home", textSize: 18) {
                        action(.home)
                    }
                    .frame(width: 100)
                    
                    if vm.enemy.id + 1 < vm.allHeroes.count || status == .lose {
                        ButtonView(text: status == .win ? "Next\nBattle" : "Try\nAgain", textSize: 18) {
                            switch status {
                            case .win:
                                action(.next)
                            case .lose:
                                action(.again)
                            }
                        }
                        .frame(width: 100)
                    }
                }
                .padding(14)
            }
        }
        .padding(.vertical, 12)
        .background {
            BackgroundView()
            RoundedRectangle(cornerRadius: 16)
                .stroke(lineWidth: 6)
                .fill(Color.yellowLight)
        }
    }
}

#Preview {
    WinLoseView(status: .win) { _ in }
}
