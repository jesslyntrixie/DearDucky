// DearDucky/Views/Ritual/Components/FoldArrow.swift

import SwiftUI

// Animated directional arrows rendered ON the paper to show where / which way to fold.

struct FoldArrow: View {
    let step: Int
    let accentColor: Color
    @State private var pulse = false

    var body: some View {
        ZStack {
            switch step {

            case 0:
                arrow("arrow.right")
                    .offset(x: -80)
                    .offset(x: pulse ? 10 : 2, y: 0)
            case 1:
                arrow("arrow.left")
                    .offset(x: 38, y: 0)
                    .offset(x: pulse ? -8 : 0)
            case 2:
                arrow("arrow.down.right")
                    .offset(x: -90, y: -110)
                    .offset(x: pulse ? 5 : 0, y: pulse ? 5 : 0)
                arrow("arrow.down.left")
                    .offset(x: 90, y: -110)
                    .offset(x: pulse ? -5 : 0, y: pulse ? 5 : 0)
            case 3:
                arrow("arrow.down.right")
                    .offset(x: -85, y: 5)
                    .offset(x: pulse ? 5 : 0, y: pulse ? 5 : 0)
                arrow("arrow.down.left")
                    .offset(x: 85, y: 5)
                    .offset(x: pulse ? -5 : 0, y: pulse ? 5 : 0)
            case 4:
                arrow("arrow.right")
                    .offset(x: -50)
                    .offset(x: pulse ? 10 : 2, y: 0)
            case 5:
                arrow("arrow.down.left")
                    .offset(x: 18, y: -55)
                    .offset(y: pulse ? 8 : 0)
            case 6:
                arrow("arrow.2.circlepath")
                    .scaleEffect(pulse ? 1.15 : 1.0)
            case 7:
                arrow("arrow.down.right")
                    .offset(x: -28, y: -50)
                    .offset(y: pulse ? 8 : 0)
            default:
                EmptyView()
            }
        }
        .animation(.easeInOut(duration: 0.85).repeatForever(autoreverses: true), value: pulse)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { pulse = true }
        }
    }

    private func arrow(_ name: String) -> some View {
        Image(systemName: name)
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(accentColor.opacity(0.70))
            .shadow(color: accentColor.opacity(0.30), radius: 5, y: 2)
    }
}
