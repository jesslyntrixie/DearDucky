// DearDucky/Views/Shared

import Foundation
import SwiftUI

// ─────────────────────────────────────────────
// MARK: - Stamp decoration
// ─────────────────────────────────────────────
struct StampDecoration: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3)
                .strokeBorder(Color.peach.opacity(0.50),
                              style: StrokeStyle(lineWidth: 1.2, dash: [2.5, 2]))
                .frame(width: 30, height: 36)
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.paperCream.opacity(0.55))
                .frame(width: 22, height: 28)
            Image(systemName: "heart.fill")
                .font(.system(size: 11))
                .foregroundColor(.blush)
        }
        .padding(.top, 12)
    }
}
