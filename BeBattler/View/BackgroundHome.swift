
import SwiftUI


struct BackgroundHome: View {
    
    var overlaySize: CGFloat = 2.7
    
    var body: some View {
        ZStack(alignment: .center) {
            Image("backgroundLightning")
                .resizable()
                .scaledToFit()
                .rotationEffect(.degrees(180), anchor: .center)
                .frame(width: screen.width * 1.1, height: screen.height * 1.1)
                .offset(y: -screen.height / overlaySize)
            
            Image("backgroundLightning")
                .resizable()
                .scaledToFit()
                .frame(width: screen.width * 1.1, height: screen.height * 1.1)
                .offset(y: screen.height / overlaySize)
        }
        .background {
            BackgroundView()
        }
    }
}

#Preview {
    BackgroundHome()
        .environmentObject(ViewModel())
}
