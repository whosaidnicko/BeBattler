
import SwiftUI

struct SplashScreen: View {
    @State private var progress: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .center) {
            Circle()
                .scaledToFit()
                .padding(screen.height / 3)
                .foregroundStyle(LinearGradient(colors: [.yellowLight, .yellowDeep], startPoint: .top, endPoint: .bottom))
            
            Circle()
                .stroke(style: .init(lineWidth: 5))
                .scaledToFit()
                .padding(screen.height / 3)
                .foregroundStyle(.yellowLight)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(style: .init(lineWidth: 5))
                .scaledToFit()
                .padding(screen.height / 3)
                .foregroundStyle(Color.white)
                .rotationEffect(.degrees(-90))
            
            Text("Loading")
                .font(.custom(LocalFont.regular.rawValue, size: 32))
                .foregroundStyle(.white)
                .shadow(color: .black, radius: 1, x: 2, y: 2)
 
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3)) {
                progress = 1
            }
        }
    }
}

#Preview {
    SplashScreen()
}
