
import SwiftUI

struct DismissButton: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Button {
            dismiss()
        } label: {
            Image("arrowBack")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .padding(.horizontal, 30)
                .padding(.top, screen.height / screen.width < 0.5 ? 40 : 20)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    DismissButton()
}
