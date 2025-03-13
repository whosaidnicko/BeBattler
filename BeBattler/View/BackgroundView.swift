
import SwiftUI

struct BackgroundView: View {
    var overlaySize: CGFloat = 2.7
    
    var body: some View {
        ZStack {
            Image("back")
                .resizable()
                .scaledToFill()
            LinearGradient(colors: [.greenDeep, .greenLight, .greenDeep], startPoint: .topLeading, endPoint: .bottomTrailing)
                .opacity(0.6)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
        .environmentObject(ViewModel())
}
