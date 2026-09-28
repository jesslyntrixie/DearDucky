// DearDucky/Views/Write/Components

import SwiftUI
import Foundation

struct SendButton: View {
    let colorIndex: Int
    let enabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(EnvelopePalette.shadow(colorIndex))
                    .frame(width: 54, height: 54)
                    .offset(y: 4)
                Circle()
                    .fill(EnvelopePalette.main(colorIndex))
                    .frame(width: 54, height: 54)
                Image(systemName: "paperplane.fill")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.white)
                    .offset(x: 1, y: -1)
            }
        }
        .disabled(!enabled)
        .opacity(enabled ? 1.0 : 0.30)
        .scaleEffect(enabled ? 1.0 : 0.90)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: enabled)
    }
}

