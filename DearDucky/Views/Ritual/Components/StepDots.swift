// DearDucky/Views/Ritual/Components/StepDots.swift

import SwiftUI

struct StepDots: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<totalSteps, id: \.self) { i in
                Capsule()
                    .fill(i <= currentStep ? Color.inkColor.opacity(0.65) : Color.inkColor.opacity(0.16))
                    .frame(width: i == currentStep ? 20 : 7, height: 7)
                    .animation(.spring(response: 0.3, dampingFraction: 0.65), value: currentStep)
            }
        }
    }
}
