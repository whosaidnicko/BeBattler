
import SwiftUI

struct SettingsScreen: View {
    @EnvironmentObject var vm: ViewModel
    
    @State private var showPrivacy = false
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            HStack(alignment: .center) {
                Group {
                    ButtonView(
                        text: "Mysic\n\(vm.musicOn ? "ON" : "OFF")",
                        textSize: 28,
                        colorStyle: vm.musicOn ? .isOn : .isOff
                    ) {
                        vm.musicOn.toggle()
                    }
                    
                    ButtonView(
                        text: "Sound\n\(vm.soundOn ? "ON" : "OFF")",
                        textSize: 28,
                        colorStyle: vm.soundOn ? .isOn : .isOff
                    ) {
                        vm.soundOn.toggle()
                    }
                }
                .frame(width: screen.height / 3)
                .padding()
                
                Spacer()
                
                ButtonView(text: "Privacy\nPolicy", textSize: 22) {
                    showPrivacy = true
                }
                .frame(width: screen.height / 4)
            }
            .padding(.horizontal, 12)
        }
        .sheet(isPresented: $showPrivacy) {
            ZStack {
                Color.grayLight
                    .ignoresSafeArea()
                Text("Privacy Policy HERE")
            }
            .overlay(alignment: .topLeading) {
                DismissButton()
                   
            }
        }
        .overlay(alignment: .topLeading) {
            DismissButton()
        }
    }
}

#Preview {
    SettingsScreen()
        .environmentObject(ViewModel())
}
