import SwiftUI
import Foundation
import SwiftData

struct WriteView: View {
    @FocusState private var focusedField: LetterCard.CardField?
    @Environment(\.modelContext) private var modelContext
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var envelopeColorIndex: Int = 0
    @State private var showRitual = false

    var canSend: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        GeometryReader { geo in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // Section 1 — sky + duck hero (half screen)
                    MascotHeroSection()
                        .frame(height: geo.size.height * 0.38)

                    // Section 2 — writing area on garden green
                    ZStack(alignment: .top) {
                        Color.mintFresh

                        VStack(spacing: 20) {
                            LetterCard(title: $title, content: $content, focusedField: $focusedField)

                            HStack(spacing: 12) {
                                EnvelopeColorPicker(selectedIndex: $envelopeColorIndex)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(Capsule().fill(Color.white.opacity(0.88)))

                                Spacer()

                                SendButton(colorIndex: envelopeColorIndex, enabled: canSend) {
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    showRitual = true
                                }
                            }

                            Spacer(minLength: 64)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                    .frame(minHeight: geo.size.height * 0.60)
                }
            }
            // Background: sky blue top half, garden green bottom half.
            // Both rubber-band bounce zones show the right colour.
            // ignoresSafeArea covers the status bar with sky blue.
            .background(
                GeometryReader { bg in
                    VStack(spacing: 0) {
                        Color.skyBright.frame(height: bg.size.height * 0.50)
                        Color.mintFresh
                    }
                    .ignoresSafeArea()
                }
            )
        }
        .fullScreenCover(isPresented: $showRitual) {
            RitualView(
                envelopeColorIndex: envelopeColorIndex,
                onComplete: { saveAndReset(); showRitual = false },
                onCancel:   { showRitual = false }
            )
        }
        .onTapGesture {
            focusedField = nil
        }
    }

    private func saveAndReset() {
        focusedField = nil
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        modelContext.insert(Letter(
            title: title,
            content: content,
            envelopeColorIndex: envelopeColorIndex
        ))
        title = ""
        content = ""
        envelopeColorIndex = Int.random(in: 0..<6)
    }
}
