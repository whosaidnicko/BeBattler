
import SwiftUI

enum ButtonColorStyle {
    case isOn, isOff
}

struct ButtonView: View {
    
    let text: String
    var textSize: CGFloat = 32
    var colorStyle: ButtonColorStyle = .isOn
    
    let action: () -> ()
    
    var body: some View {
        Button {
            action()
        } label: {
            label
        }
        .buttonStyle(GameButtonStyle())
    }
    
    private var label: some View {
        ZStack {
            Circle()
                .scaledToFit()
                .foregroundStyle(getGradient())
            
            Circle()
                .stroke(style: .init(lineWidth: 5))
                .scaledToFit()
              
                .foregroundStyle(colorStyle == .isOn ? .yellowLight : .grayLight)
            
            Text(text)
                .font(.custom(LocalFont.regular.rawValue, size: textSize))
                .foregroundStyle(.white)
                .shadow(color: .black, radius: 1, x: 2, y: 2)
                .lineLimit(2)
                .scaledToFit()
        }
    }
    
    private func getGradient() -> LinearGradient {
        switch colorStyle {
        case .isOn:
            LinearGradient(colors: [.yellowLight, .yellowDeep], startPoint: .top, endPoint: .bottom)
        case .isOff:
            LinearGradient(colors: [.grayLight, .grayDeep], startPoint: .top, endPoint: .bottom)
        }
    }
}
