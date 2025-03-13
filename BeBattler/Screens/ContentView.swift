
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var vm: ViewModel
    @State private var splashIsDone = false
    @State private var overlaySize: CGFloat = 2.7
    
    var body: some View {
        ZStack {
            BackgroundHome(overlaySize: overlaySize)
            
            if !splashIsDone {
                SplashScreen()
                    .ignoresSafeArea()
            } else {
                HomeScreen()
            }
        }
        .fixedSize()
        .whopaixzb()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.easeIn(duration: 1)) {
                    splashIsDone = true
                    overlaySize = 2.5
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ViewModel())
}
