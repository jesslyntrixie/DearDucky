import SwiftUI
import SwiftData

struct GalleryView: View {
    @Query(sort: \Letter.timestamp, order: .reverse) private var letters: [Letter]

    var body: some View {
        ZStack {
            // Flat sky — matches hero section, no gradient
            Color.skyBright
                .ignoresSafeArea()

            if letters.isEmpty {
                EmptyGalleryView()
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 22) {
                        ForEach(letters) { letter in
                            EnvelopeCard(letter: letter)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 44)
                }
            }
        }
        .navigationTitle("My Letters")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Envelope Card (unchanged)

struct EnvelopeCard: View {
    let letter: Letter
    @State private var isOpen = false

    private var main:  Color { EnvelopePalette.main(letter.envelopeColorIndex) }
    private var light: Color { EnvelopePalette.light(letter.envelopeColorIndex) }

    var body: some View {
        VStack(spacing: 0) {

            // ── Flap (folds back when open) ──
            GeometryReader { geo in
                ZStack {
                    light.opacity(0.55)
                    Path { path in
                        path.move(to: .init(x: 0, y: 0))
                        path.addLine(to: .init(x: geo.size.width, y: 0))
                        path.addLine(to: .init(x: geo.size.width / 2, y: geo.size.height))
                        path.closeSubpath()
                    }
                    .fill(main.opacity(0.30))

                    Path { path in
                        path.move(to: .init(x: 0, y: 0))
                        path.addLine(to: .init(x: geo.size.width, y: 0))
                        path.addLine(to: .init(x: geo.size.width / 2, y: geo.size.height))
                        path.closeSubpath()
                    }
                    .stroke(main.opacity(0.42), lineWidth: 1.5)
                }
            }
            .frame(height: 50)
            .rotation3DEffect(
                .degrees(isOpen ? -180 : 0),
                axis: (x: 1, y: 0, z: 0),
                anchor: .top,
                perspective: 0.35
            )
            .zIndex(1)
            .clipped()

            // ── Envelope body ──
            ZStack(alignment: .top) {
                Rectangle()
                    .fill(light.opacity(0.28))
                    .overlay(
                        Rectangle()
                            .strokeBorder(main.opacity(0.35), lineWidth: 1.5)
                    )

                if !isOpen {
                    GeometryReader { geo in
                        ZStack {
                            Path { path in
                                path.move(to: .init(x: 0, y: 0))
                                path.addLine(to: .init(x: geo.size.width / 2, y: geo.size.height * 0.55))
                            }
                            .stroke(main.opacity(0.18), lineWidth: 1.1)

                            Path { path in
                                path.move(to: .init(x: geo.size.width, y: 0))
                                path.addLine(to: .init(x: geo.size.width / 2, y: geo.size.height * 0.55))
                            }
                            .stroke(main.opacity(0.18), lineWidth: 1.1)
                        }
                    }
                    .transition(.opacity)
                }

                if isOpen {
                    LetterPaperView(letter: letter, accentColor: main)
                        .padding(14)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .offset(y: 16)),
                            removal:   .opacity.combined(with: .offset(y: 16))
                        ))
                } else {
                    HStack(alignment: .center, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(letter.title)
                                .font(.system(.headline, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(.inkColor)
                                .lineLimit(1)
                            Text(letter.timestamp, style: .date)
                                .font(.system(.caption, design: .rounded))
                                .foregroundColor(main)
                        }
                        Spacer()
                        WaxSeal(color: main, size: 36)
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 16)
                }
            }
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: 18,
                    bottomTrailingRadius: 18,
                    topTrailingRadius: 0
                )
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: main.opacity(0.22), radius: 14, y: 6)
        .onTapGesture {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(.spring(response: 0.52, dampingFraction: 0.74)) {
                isOpen.toggle()
            }
        }
    }
}

// MARK: - Letter Paper (unchanged)

struct LetterPaperView: View {
    let letter: Letter
    let accentColor: Color

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(red: 0.78, green: 0.72, blue: 0.58).opacity(0.42))
                .offset(x: 2, y: 5)

            RoundedRectangle(cornerRadius: 14)
                .fill(Color.paperCream)

            VStack(spacing: 0) {
                Spacer().frame(height: 72)
                ForEach(0..<11, id: \.self) { _ in
                    Spacer()
                    Rectangle()
                        .fill(Color.skyBright.opacity(0.18))
                        .frame(height: 1)
                }
                Spacer()
            }
            .clipShape(RoundedRectangle(cornerRadius: 14))

            Rectangle()
                .fill(Color.peach.opacity(0.42))
                .frame(width: 1.5)
                .padding(.leading, 46)
                .clipShape(RoundedRectangle(cornerRadius: 14))

            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Spacer()
                    Text(letter.timestamp, style: .date)
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.inkColor.opacity(0.36))
                        .padding(.trailing, 14)
                        .padding(.top, 12)
                }

                Text(letter.title)
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.inkColor)
                    .padding(.leading, 56)
                    .padding(.trailing, 14)

                Rectangle()
                    .fill(Color.inkColor.opacity(0.08))
                    .frame(height: 1)
                    .padding(.leading, 56)
                    .padding(.trailing, 14)

                Text(letter.content)
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.inkColor.opacity(0.84))
                    .padding(.leading, 54)
                    .padding(.trailing, 12)
                    .padding(.bottom, 16)
            }
        }
        .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
    }
}

// MARK: - Empty State (unchanged)

struct EmptyGalleryView: View {
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.30))
                    .frame(width: 108, height: 108)
                Text("📬")
                    .font(.system(size: 52))
            }
            Text("No letters yet")
                .font(.system(.title2, design: .rounded))
                .fontWeight(.heavy)
                .foregroundColor(.white)
            Text("Write your first letter to\nyour future self!")
                .font(.system(.body, design: .rounded))
                .foregroundColor(.white.opacity(0.72))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
