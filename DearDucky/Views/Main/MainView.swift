// DearDucky/Views/Main/MainView

import SwiftUI
import SwiftData


enum AppTab { case write, letters}


struct MainView: View {
    @State private var activeTab: AppTab = .write

    var body: some View {
        Group {
            switch activeTab {
            case .write:
                WriteView()
            case .letters:
                NavigationStack { GalleryView() }
            }
        }
        .animation(.easeInOut(duration: 0.20), value: activeTab)
        .safeAreaInset( edge: .bottom, spacing: 0) {
            GrassTabView(activeTab: $activeTab)
                .ignoresSafeArea(.keyboard)
        }
    }
}

#Preview {
    MainView()
}
