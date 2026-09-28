// DearDucky/Views/Main/GrassTabView
import SwiftUI



struct GrassTabView: View {
    @Binding var activeTab: AppTab

    var body: some View {
        HStack(spacing: 0) {
            DockTab(icon: "pencil.tip",        label: "Write",   isActive: activeTab == .write,   activeColor: .yellow) { activeTab = .write }
            DockTab(icon: "envelope.fill", label: "Letters", isActive: activeTab == .letters, activeColor: .yellow)   { activeTab = .letters }
        }
        .padding(.top, 10)
        .background(Color.gardenGreen)
    }
}


struct DockTab: View {
    let icon: String
    let label: String
    let isActive: Bool
    let activeColor: Color
    let action: () -> Void

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        } label: {
            VStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 23, weight: isActive ? .bold : .regular))
                    .foregroundColor(isActive ? .white : .white.opacity(0.4))

                Text(label)
                    .font(.system(size: 10, weight: isActive ? .bold : .medium, design: .rounded))
                    .foregroundColor(isActive ? .white : .white.opacity(0.4))  
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 24)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(isActive ? 0.28 : 0))
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isActive)
        }
        .frame(maxWidth: .infinity)
        .buttonStyle(.plain)
    }
}
