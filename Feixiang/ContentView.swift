import SwiftUI
import SwiftData

// ─────────────────────────────────────────────
// MARK: - Root container — native tab bar (3 tabs)
// ─────────────────────────────────────────────
struct ContentView: View {
    var body: some View {
        TabView {
            WriteView()
                .tabItem { Label("Write", systemImage: "pencil") }

            NavigationStack {
                GalleryView()
            }
            .tabItem { Label("Letters", systemImage: "envelope.fill") }

            DuckyProfileView()
                .tabItem { Label("Ducky", systemImage: "face.smiling.fill") }
        }
        .tint(.skyBright)
    }
}

// ─────────────────────────────────────────────
// MARK: - Write page (scrollable, two sections)
// ─────────────────────────────────────────────
struct WriteView: View {
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

                    // ── Section 1: Mascot hero (fills exactly one screen) ──
                    MascotHeroSection()
                        .frame(height: geo.size.height)

                    // ── Section 2: Writing area ──
                    ZStack(alignment: .top) {
                        Color(red: 0.96, green: 0.93, blue: 0.86)
                            .ignoresSafeArea()

                        VStack(spacing: 20) {

                            // Duck greeting (replaces "Lettera" wordmark)
                            HStack(spacing: 8) {
                                Text("🦆")
                                    .font(.system(size: 20))
                                Text("Dear future me,")
                                    .font(.system(.subheadline, design: .rounded))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.inkColor.opacity(0.52))
                                    .tracking(0.5)
                            }
                            .padding(.top, 32)

                            // Paper card
                            CleanLetterCard(title: $title, content: $content)

                            // Color picker + send
                            HStack(spacing: 8) {
                                EnvelopeColorPicker(selectedIndex: $envelopeColorIndex)
                                Spacer()
                                Button {
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                    showRitual = true
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(EnvelopePalette.main(envelopeColorIndex).opacity(0.40))
                                            .frame(width: 54, height: 54)
                                            .offset(y: 4)
                                        Circle()
                                            .fill(EnvelopePalette.main(envelopeColorIndex))
                                            .frame(width: 54, height: 54)
                                        Image(systemName: "paperplane.fill")
                                            .font(.system(size: 20, weight: .semibold))
                                            .foregroundColor(.white)
                                            .offset(x: 1, y: -1)
                                    }
                                }
                                .disabled(!canSend)
                                .opacity(canSend ? 1.0 : 0.32)
                                .scaleEffect(canSend ? 1.0 : 0.92)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: canSend)
                            }

                            Spacer(minLength: 110)
                        }
                        .padding(.horizontal, 22)
                    }
                    .frame(minHeight: geo.size.height)
                }
            }
        }
        .ignoresSafeArea()
        .fullScreenCover(isPresented: $showRitual) {
            RitualView(
                envelopeColorIndex: envelopeColorIndex,
                onComplete: { saveAndReset(); showRitual = false },
                onCancel:   { showRitual = false }
            )
        }
    }

    private func saveAndReset() {
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

// ─────────────────────────────────────────────
// MARK: - Mascot Hero Section
// ─────────────────────────────────────────────
struct MascotHeroSection: View {
    @State private var bobOffset: CGFloat = 0
    @State private var chevronOpacity: Double = 0.5

    var body: some View {
        ZStack {
            Color.skyBright
                .ignoresSafeArea()

            // Hills + scene details
            GeometryReader { geo in
                ZStack {
                    // Back hill (lighter)
                    Ellipse()
                        .fill(Color.mintFresh)
                        .frame(width: geo.size.width * 1.5, height: 230)
                        .offset(x: -geo.size.width * 0.25, y: geo.size.height - 145)

                    // Front hill (solid green)
                    Ellipse()
                        .fill(Color.gardenGreen)
                        .frame(width: geo.size.width * 1.3, height: 195)
                        .offset(x: geo.size.width * 0.05, y: geo.size.height - 112)

                    // ── Tree on back hill (left side) ──
                    // Trunk
                    Rectangle()
                        .fill(Color(red: 0.50, green: 0.32, blue: 0.15))
                        .frame(width: 7, height: 24)
                        .offset(x: -geo.size.width * 0.22, y: geo.size.height - 62)
                    // Canopy
                    Circle()
                        .fill(Color.leafGreen)
                        .frame(width: 36, height: 36)
                        .offset(x: -geo.size.width * 0.22, y: geo.size.height - 90)

                    // Smaller second tree
                    Rectangle()
                        .fill(Color(red: 0.50, green: 0.32, blue: 0.15))
                        .frame(width: 5, height: 17)
                        .offset(x: -geo.size.width * 0.10, y: geo.size.height - 57)
                    Circle()
                        .fill(Color(red: 0.10, green: 0.50, blue: 0.30))
                        .frame(width: 26, height: 26)
                        .offset(x: -geo.size.width * 0.10, y: geo.size.height - 79)

                    // ── Mailbox on front hill (right side) ──
                    // Post
                    Rectangle()
                        .fill(Color(red: 0.50, green: 0.32, blue: 0.15))
                        .frame(width: 4, height: 18)
                        .offset(x: geo.size.width * 0.28, y: geo.size.height - 37)
                    // Box body
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(red: 0.20, green: 0.52, blue: 0.92))
                        .frame(width: 20, height: 13)
                        .offset(x: geo.size.width * 0.28, y: geo.size.height - 51)
                    // Mailbox flag (coral red)
                    Rectangle()
                        .fill(Color.coral)
                        .frame(width: 2, height: 8)
                        .offset(x: geo.size.width * 0.28 + 11, y: geo.size.height - 54)

                    // Small yellow flowers
                    let flowerXs: [CGFloat] = [50, 150, 240, 310]
                    let flowerYs: [CGFloat] = [-28, -20, -34, -18]
                    ForEach(0..<4, id: \.self) { i in
                        Circle()
                            .fill(Color.sunYellow)
                            .frame(width: 11, height: 11)
                            .offset(x: flowerXs[i], y: geo.size.height + flowerYs[i] - 28)
                    }
                }
            }

            // Flat white clouds
            VStack {
                HStack(alignment: .top) {
                    CloudView(scale: 0.90, opacity: 1.0)
                        .offset(x: -6, y: 62)
                    Spacer()
                    CloudView(scale: 0.60, opacity: 1.0)
                        .offset(x: 10, y: 90)
                }
                .padding(.horizontal, 12)
                Spacer()
            }

            // Duck mascot + greeting + scroll hint
            VStack(spacing: 0) {
                Spacer()

                // Duck mascot with gentle bob
                MascotDuckView()
                    .frame(width: 130, height: 140)
                    .offset(y: bobOffset)
                    .onAppear {
                        withAnimation(
                            .easeInOut(duration: 1.8)
                            .repeatForever(autoreverses: true)
                        ) {
                            bobOffset = -9
                        }
                    }

                Spacer().frame(height: 20)

                // Greeting text — Ducky introduces herself
                VStack(spacing: 4) {
                    Text("Hi, I'm Ducky! 🦆")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.85))
                    Text("What would you tell")
                        .font(.system(size: 25, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                    Text("your future self?")
                        .font(.system(size: 25, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                }
                .multilineTextAlignment(.center)
                .shadow(color: .black.opacity(0.08), radius: 4, y: 2)

                Spacer()

                // Scroll hint (pulsing chevron)
                VStack(spacing: 5) {
                    Image(systemName: "chevron.compact.down")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white.opacity(chevronOpacity))
                        .onAppear {
                            withAnimation(
                                .easeInOut(duration: 1.1)
                                .repeatForever(autoreverses: true)
                            ) {
                                chevronOpacity = 1.0
                            }
                        }
                    Text("scroll to write")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.white.opacity(0.55))
                }
                .padding(.bottom, 40)
            }
        }
    }
}

// ─────────────────────────────────────────────
// MARK: - Mascot Duck 🦆
// ─────────────────────────────────────────────
struct MascotDuckView: View {
    var body: some View {
        ZStack {
            // Ground shadow
            Ellipse()
                .fill(Color.black.opacity(0.09))
                .frame(width: 72, height: 14)
                .offset(y: 62)

            // Body
            Ellipse()
                .fill(Color.sunYellow)
                .frame(width: 84, height: 70)
                .offset(y: 18)

            // Left wing (slightly darker yellow)
            Ellipse()
                .fill(Color(red: 0.94, green: 0.75, blue: 0.10))
                .frame(width: 30, height: 18)
                .rotationEffect(.degrees(-18))
                .offset(x: -48, y: 14)

            // Right wing
            Ellipse()
                .fill(Color(red: 0.94, green: 0.75, blue: 0.10))
                .frame(width: 30, height: 18)
                .rotationEffect(.degrees(18))
                .offset(x: 48, y: 14)

            // Head
            Circle()
                .fill(Color.sunYellow)
                .frame(width: 64, height: 64)
                .offset(y: -8)

            // Head tuft — 3 little bumps on top
            Circle()
                .fill(Color(red: 0.94, green: 0.75, blue: 0.10))
                .frame(width: 11, height: 16)
                .offset(x: -8, y: -38)
            Circle()
                .fill(Color(red: 0.94, green: 0.75, blue: 0.10))
                .frame(width: 13, height: 18)
                .offset(x: 0, y: -42)
            Circle()
                .fill(Color(red: 0.94, green: 0.75, blue: 0.10))
                .frame(width: 11, height: 16)
                .offset(x: 8, y: -38)

            // Eyes
            Circle()
                .fill(Color(red: 0.10, green: 0.08, blue: 0.12))
                .frame(width: 10, height: 10)
                .offset(x: -13, y: -12)
            Circle()
                .fill(Color(red: 0.10, green: 0.08, blue: 0.12))
                .frame(width: 10, height: 10)
                .offset(x: 13, y: -12)

            // Eye shine
            Circle()
                .fill(Color.white)
                .frame(width: 3.5, height: 3.5)
                .offset(x: -11, y: -14)
            Circle()
                .fill(Color.white)
                .frame(width: 3.5, height: 3.5)
                .offset(x: 15, y: -14)

            // Cheek blush spots
            Ellipse()
                .fill(Color.peach.opacity(0.52))
                .frame(width: 15, height: 10)
                .offset(x: -22, y: -6)
            Ellipse()
                .fill(Color.peach.opacity(0.52))
                .frame(width: 15, height: 10)
                .offset(x: 22, y: -6)

            // Bill — wide, flat, orange (duck-style)
            Ellipse()
                .fill(Color(red: 1.00, green: 0.52, blue: 0.12))
                .frame(width: 24, height: 11)
                .offset(y: -3)
            // Bill crease
            Capsule()
                .fill(Color(red: 0.80, green: 0.36, blue: 0.08).opacity(0.42))
                .frame(width: 16, height: 1.5)
                .offset(y: -3)

            // Left foot — 3 small toe capsules fanned out
            ZStack {
                Capsule()
                    .fill(Color(red: 1.00, green: 0.52, blue: 0.12))
                    .frame(width: 14, height: 5)
                    .rotationEffect(.degrees(-22))
                    .offset(x: -5)
                Capsule()
                    .fill(Color(red: 1.00, green: 0.52, blue: 0.12))
                    .frame(width: 14, height: 5)
                Capsule()
                    .fill(Color(red: 1.00, green: 0.52, blue: 0.12))
                    .frame(width: 14, height: 5)
                    .rotationEffect(.degrees(22))
                    .offset(x: 5)
            }
            .offset(x: -18, y: 58)

            // Right foot
            ZStack {
                Capsule()
                    .fill(Color(red: 1.00, green: 0.52, blue: 0.12))
                    .frame(width: 14, height: 5)
                    .rotationEffect(.degrees(-22))
                    .offset(x: -5)
                Capsule()
                    .fill(Color(red: 1.00, green: 0.52, blue: 0.12))
                    .frame(width: 14, height: 5)
                Capsule()
                    .fill(Color(red: 1.00, green: 0.52, blue: 0.12))
                    .frame(width: 14, height: 5)
                    .rotationEffect(.degrees(22))
                    .offset(x: 5)
            }
            .offset(x: 18, y: 58)
        }
    }
}

// ─────────────────────────────────────────────
// MARK: - Ducky Profile Tab (3rd tab)
// ─────────────────────────────────────────────
struct DuckyProfileView: View {
    @Query(sort: \Letter.timestamp, order: .reverse) private var letters: [Letter]
    @State private var bobOffset: CGFloat = 0

    private var totalLetters: Int { letters.count }

    private var daysSinceFirst: Int {
        guard let oldest = letters.map(\.timestamp).min() else { return 0 }
        return max(1, Calendar.current.dateComponents([.day], from: oldest, to: .now).day ?? 1)
    }

    private var encouragementText: String {
        if totalLetters == 0 {
            return "Every journey starts with one letter.\nWrite your first one! 💌"
        } else if totalLetters == 1 {
            return "You've started something beautiful.\nKeep writing to your future self! 🌟"
        } else {
            return "Your future self has \(totalLetters) letters waiting.\nThey'll be so happy to read them! ✨"
        }
    }

    var body: some View {
        ZStack {
            // Sky gradient (consistent with rest of app)
            LinearGradient(
                colors: [Color.skyDeep, Color.skyBright, Color.skyLight],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            // Soft clouds
            CloudView(scale: 0.85, opacity: 0.80).position(x: 70,  y: 120)
            CloudView(scale: 0.60, opacity: 0.65).position(x: 310, y: 170)

            VStack(spacing: 28) {
                Spacer()

                // Large duck mascot
                MascotDuckView()
                    .frame(width: 160, height: 170)
                    .scaleEffect(1.18)
                    .offset(y: bobOffset)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                            bobOffset = -9
                        }
                    }

                // Name
                Text("Hi, I'm Ducky!")
                    .font(.system(.title, design: .rounded))
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.08), radius: 4, y: 2)

                // Stats row
                HStack(spacing: 16) {
                    DuckyStatCard(
                        number: "\(totalLetters)",
                        label: "Letters\nSent",
                        icon: "envelope.fill"
                    )
                    DuckyStatCard(
                        number: totalLetters > 0 ? "\(daysSinceFirst)" : "—",
                        label: "Days\nWriting",
                        icon: "calendar.badge.clock"
                    )
                }
                .padding(.horizontal, 40)

                // Encouragement bubble
                Text(encouragementText)
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.white.opacity(0.92))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color.white.opacity(0.18))
                    )
                    .padding(.horizontal, 32)

                Spacer()
                Spacer()
            }
        }
        .navigationTitle("Ducky")
    }
}

struct DuckyStatCard: View {
    let number: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.sunYellow)
            Text(number)
                .font(.system(.title, design: .rounded))
                .fontWeight(.heavy)
                .foregroundColor(.white)
            Text(label)
                .font(.system(.caption, design: .rounded))
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.72))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 22)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.18))
        )
    }
}

// ─────────────────────────────────────────────
// MARK: - Clean Letter Card (unchanged)
// ─────────────────────────────────────────────
struct CleanLetterCard: View {
    @Binding var title: String
    @Binding var content: String
    @FocusState private var focusedField: CardField?

    enum CardField { case title, content }

    var body: some View {
        ZStack(alignment: .topLeading) {

            // Paper thickness shadow
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(red: 0.78, green: 0.72, blue: 0.58).opacity(0.45))
                .offset(x: 3, y: 7)
                .allowsHitTesting(false)

            // Paper body
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.paperCream)
                .allowsHitTesting(false)

            // Left margin line
            Rectangle()
                .fill(Color.peach.opacity(0.42))
                .frame(width: 1.5)
                .padding(.leading, 54)
                .clipShape(RoundedRectangle(cornerRadius: 22))
                .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: 0) {

                HStack(alignment: .top, spacing: 8) {
                    Spacer()
                    Text(Date(), style: .date)
                        .font(.system(.caption2, design: .rounded))
                        .foregroundColor(.inkColor.opacity(0.30))
                        .padding(.top, 20)
                        .padding(.trailing, 20)
                    StampDecoration()
                }
                .padding(.trailing, 18)

                TextField("Give your letter a title…", text: $title)
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.inkColor)
                    .focused($focusedField, equals: .title)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .content }
                    .padding(.leading, 66)
                    .padding(.trailing, 22)
                    .padding(.top, 2)

                Rectangle()
                    .fill(Color.inkColor.opacity(0.07))
                    .frame(height: 1)
                    .padding(.leading, 66)
                    .padding(.trailing, 22)
                    .padding(.vertical, 8)

                ZStack(alignment: .topLeading) {
                    if content.isEmpty {
                        Text("Write anything — hopes, gratitude, goals, fears.\nYour future self will read this.")
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(.inkColor.opacity(0.22))
                            .padding(.leading, 66)
                            .padding(.trailing, 22)
                            .padding(.top, 8)
                            .allowsHitTesting(false)
                    }
                    TextEditor(text: $content)
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.inkColor)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .focused($focusedField, equals: .content)
                        .padding(.leading, 62)
                        .padding(.trailing, 18)
                        .padding(.bottom, 16)
                        .frame(minHeight: 170)
                }
            }
        }
        .shadow(color: .black.opacity(0.07), radius: 16, y: 8)
        .onTapGesture {
            if focusedField == nil { focusedField = title.isEmpty ? .title : .content }
        }
    }
}

// ─────────────────────────────────────────────
// MARK: - Stamp decoration (unchanged)
// ─────────────────────────────────────────────
struct StampDecoration: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3)
                .strokeBorder(
                    Color.peach.opacity(0.50),
                    style: StrokeStyle(lineWidth: 1.2, dash: [2.5, 2])
                )
                .frame(width: 30, height: 36)
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.paperCream.opacity(0.55))
                .frame(width: 22, height: 28)
            Image(systemName: "heart.fill")
                .font(.system(size: 11))
                .foregroundColor(.blush.opacity(1.0))
        }
        .padding(.top, 12)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Letter.self, inMemory: true)
}
