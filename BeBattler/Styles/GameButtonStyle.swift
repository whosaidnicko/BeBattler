
import SwiftUI

struct GameButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        let scale = configuration.isPressed ? 0.9 : 1
        let animation : Animation = .easeOut(duration: 0.4)
        let opacity = configuration.isPressed ? 0.9 : 1
        return configuration.label
            .opacity(opacity)
            .scaleEffect(scale)
            .animation(animation, value: configuration.isPressed)
            .multilineTextAlignment(.center)
    }
}

