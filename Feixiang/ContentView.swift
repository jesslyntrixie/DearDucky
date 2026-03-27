import SwiftUI
import SwiftData

// ─────────────────────────────────────────────
// MARK: - App Tab
// ─────────────────────────────────────────────
enum AppTab { case write, letters, ducky }

// ─────────────────────────────────────────────
// MARK: - Root
// ─────────────────────────────────────────────
struct ContentView: View {
    @State private var activeTab: AppTab = .write

    var body: some View {
        Group {
            switch activeTab {
            case .write:
                WriteView()
            case .letters:
                NavigationStack { GalleryView() }
            case .ducky:
                DuckyProfileView()
            }
        }
        .animation(.easeInOut(duration: 0.20), value: activeTab)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            GrassDock(activeTab: $activeTab)
        }
    }
}

// ─────────────────────────────────────────────
// MARK: - Grass Dock  (Finch-style)
// ─────────────────────────────────────────────
struct GrassDock: View {
    @Binding var activeTab: AppTab

    private let bladePositions: [(x: CGFloat, height: CGFloat, angle: Double)] = [
        (0.04, 10, -14), (0.10, 13,  7), (0.17,  9,  -5), (0.24, 14, 11),
        (0.31,  8, -9),  (0.38, 12,  6), (0.45, 11, -11), (0.52,  9, 12),
        (0.59, 13, -6),  (0.66, 10,  8), (0.73, 12, -13), (0.80,  9,  5),
        (0.87, 13, -8),  (0.94,  8, 10),
    ]

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geo in
                ZStack(alignment: .bottom) {
                    Color.gardenGreen
                    ForEach(bladePositions.indices, id: \.self) { i in
                        let b = bladePositions[i]
                        Capsule()
                            .fill(Color.leafGreen)
                            .frame(width: 4, height: b.height)
                            .rotationEffect(.degrees(b.angle), anchor: .bottom)
                            .position(x: geo.size.width * b.x, y: -b.height * 0.3)
                    }
                }
            }
            .frame(height: 18)

            HStack(alignment: .bottom, spacing: 0) {
                DockTab(icon: "pencil",        label: "Write",   emoji: nil,  isActive: activeTab == .write)   { activeTab = .write }
                DockTab(icon: "envelope.fill", label: "Letters", emoji: nil,  isActive: activeTab == .letters) { activeTab = .letters }
                DockTab(icon: nil,             label: "Ducky",   emoji: "🦆", isActive: activeTab == .ducky)   { activeTab = .ducky }
            }
            .padding(.top, 6)
            .padding(.bottom, 8)
            .background(Color.gardenGreen)
        }
    }
}

struct DockTab: View {
    let icon: String?
    let label: String
    let emoji: String?
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    Capsule()
                        .fill(Color.white.opacity(isActive ? 0.28 : 0))
                        .frame(width: 52, height: 34)

                    if let emoji {
                        Text(emoji)
                            .font(.title2)
                            .scaleEffect(isActive ? 1.08 : 1.0)
                    } else if let icon {
                        Image(systemName: icon)
                            .font(isActive ? .title3.bold() : .title3)
                            .foregroundColor(.white)
                    }
                }
                .animation(.spring(response: 0.28, dampingFraction: 0.65), value: isActive)

                Text(label)
                    .font(.system(.caption2, design: .rounded)
                        .weight(isActive ? .bold : .regular))
                    .foregroundColor(.white.opacity(isActive ? 1.0 : 0.62))
            }
        }
        .frame(maxWidth: .infinity)
        .scaleEffect(isActive ? 1.06 : 1.0)
        .animation(.spring(response: 0.28, dampingFraction: 0.65), value: isActive)
        .buttonStyle(.plain)
    }
}

// ─────────────────────────────────────────────
// MARK: - Write page
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

                    // Section 1 — sky + duck hero (half screen)
                    MascotHeroSection()
                        .frame(height: geo.size.height * 0.48)

                    // Section 2 — writing area on garden green
                    ZStack(alignment: .top) {
                        Color.gardenGreen

                        VStack(spacing: 20) {
                            CleanLetterCard(title: $title, content: $content)

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
                        Color.gardenGreen
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
// MARK: - Send button
// ─────────────────────────────────────────────
struct SendButton: View {
    let colorIndex: Int
    let enabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(EnvelopePalette.main(colorIndex).opacity(0.38))
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

// ─────────────────────────────────────────────
// MARK: - Mascot Hero Section
// ─────────────────────────────────────────────
struct MascotHeroSection: View {
    @State private var chevronOpacity: Double = 0.45

    var body: some View {
        ZStack {
            Color.skyBright.ignoresSafeArea()

            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height
                let trunkBrown  = Color(red: 0.50, green: 0.32, blue: 0.15)
                let stemGreen   = Color(red: 0.14, green: 0.52, blue: 0.22)
                let darkGreen   = Color(red: 0.10, green: 0.42, blue: 0.20)

                ZStack {

                    // ── Sun — top-right with soft glow ──
//                    Circle()
//                        .fill(Color.sunYellow.opacity(0.20))
//                        .frame(width: w * 0.28, height: w * 0.28)
//                        .position(x: w * 0.83, y: h * 0.18)
                    Circle()
                        .fill(Color.sunYellow.opacity(0.35))
                        .frame(width: w * 0.20, height: w * 0.20)
                        .position(x: w * 0.83, y: h * 0.18)
                    Circle()
                        .fill(Color.sunYellow)
                        .frame(width: w * 0.13, height: w * 0.13)
                        .position(x: w * 0.83, y: h * 0.18)

                    // ── Birds ──
                    BirdSilhouette()
                        .stroke(Color.white.opacity(0.70), lineWidth: 1.5)
                        .frame(width: 14, height: 7)
                        .position(x: w * 0.28, y: h * 0.18)
                    BirdSilhouette()
                        .stroke(Color.white.opacity(0.45), lineWidth: 1.2)
                        .frame(width: 10, height: 5)
                        .position(x: w * 0.40, y: h * 0.24)

                    // ── Back hill (mint) ──
                    Ellipse()
                        .fill(Color.mintFresh)
                        .frame(width: w * 1.55, height: h * 0.58)
                        .position(x: w * 0.30, y: h * 0.90)

                    // ── Front hill (garden green) ──
                    Ellipse()
                        .fill(Color.gardenGreen)
                        .frame(width: w * 1.45, height: h * 0.52)
                        .position(x: w * 0.60, y: h * 0.97)

//
                    

                    // ── Tall tree — far left ──
                    
                        

                    // ── Small tree — left-centre ──
                   

                    // ── Pond — RIGHT of duck (duck is centred ~0.50) ──
                    // Place pond at 0.68 so it's clearly to duck's right
                    Ellipse()
                        .fill(Color(red: 0.38, green: 0.72, blue: 0.96).opacity(0.88))
                        .frame(width: w * 0.22, height: h * 0.065)
                        .position(x: w * 0.68, y: h * 0.77)
                    // Highlight shimmer
                    Ellipse()
                        .fill(Color.white.opacity(0.28))
                        .frame(width: w * 0.09, height: h * 0.018)
                        .position(x: w * 0.65, y: h * 0.762)
                    // Ripple stroke
                    Ellipse()
                        .strokeBorder(Color.white.opacity(0.30), lineWidth: 0.8)
                        .frame(width: w * 0.14, height: h * 0.030)
                        .position(x: w * 0.68, y: h * 0.775)

                    // ── Mailbox — far right ──
//                    Rectangle()
//                        .fill(trunkBrown)
//                        .frame(width: 4, height: h * 0.11)
//                        .position(x: w * 0.86, y: h * 0.82)
//                    RoundedRectangle(cornerRadius: 3)
//                        .fill(Color(red: 0.20, green: 0.52, blue: 0.92))
//                        .frame(width: w * 0.10, height: h * 0.065)
//                        .position(x: w * 0.86, y: h * 0.73)
//                    Ellipse()
//                        .fill(Color(red: 0.14, green: 0.40, blue: 0.80))
//                        .frame(width: w * 0.10, height: h * 0.028)
//                        .position(x: w * 0.86, y: h * 0.700)
//                    Rectangle()
//                        .fill(Color.coral)
//                        .frame(width: 2.5, height: h * 0.048)
//                        .position(x: w * 0.86 + w * 0.057, y: h * 0.720)

                    
                    // ── Flowers with stems + leaves ──
                    // Layout: left of duck (0.22, 0.38) and right of pond (0.80)
                    let flowerX: [CGFloat] = [0.12, 0.24, 0.84, 0.70, 0.89, 0.30]
                    let flowerY: [CGFloat] = [0.87, 0.90, 0.93, 0.91, 0.89, 0.85]
                    let petalColors: [Color] = [.blush, Color(red:0.88,green:0.66,blue:1.0), .blush, Color(red:1.0,green:0.80,blue:0.60),
                        Color.white,
                                                Color.white]
                    ForEach(0..<6, id: \.self) { i in
                        let fx = w * flowerX[i]
                        let fy = h * flowerY[i]
                        // Stem
                        Rectangle()
                            .fill(stemGreen)
                            .frame(width: 2, height: h * 0.055)
                            .position(x: fx, y: fy + h * 0.038)
                        // Leaf (small rotated ellipse)
                        Ellipse()
                            .fill(stemGreen.opacity(0.85))
                            .frame(width: 9, height: 5)
                            .rotationEffect(.degrees(i % 2 == 0 ? 40 : -40))
                            .position(x: fx + (i % 2 == 0 ? 5 : -5), y: fy + h * 0.028)
                        // Petals (outer ring)
                        Circle()
                            .fill(petalColors[i].opacity(0.90))
                            .frame(width: 14, height: 14)
                            .position(x: fx, y: fy)
                        // Centre dot
                        Circle()
                            .fill(Color.sunYellow)
                            .frame(width: 6, height: 6)
                            .position(x: fx, y: fy)
                    }
                }
            }

            VStack {
                HStack(alignment: .top) {
                    CloudView(scale: 2, opacity: 1.0).offset(x: -40, y: -10)
                    Spacer()
                    CloudView(scale: 0.55, opacity: 1.0).offset(x: 8,  y: 66)
                    
                    CloudView(scale: 0.85, opacity: 1.0).offset(x: 8,  y: 66)
                }
                .padding(.horizontal, 14)
                Spacer()
            }

            VStack(spacing: 0) {
                Spacer()

                VStack() {
//                    Text("Hi, I'm Terry!")
//                        .font(.system(.headline, design: .rounded).weight(.semibold))
//                        .foregroundColor(.white.opacity(0.90))
                    Text("What would you tell")
                        .font(.system(.title2, design: .rounded).weight(.heavy))
                        .foregroundColor(.inkColor)
                    Text("your future self?")
                        .font(.system(.title2, design: .rounded).weight(.heavy))
                        .foregroundColor(.inkColor)
                        .padding(.bottom)
                    
                }
                .multilineTextAlignment(.center)
                .shadow(color: .black.opacity(0.08), radius: 3, y: 2)
                .padding(.bottom)

                MascotDuckView()
                    .frame(width: 100, height: 110)
                    .scaleEffect(0.7)

//                Image(systemName: "chevron.compact.down")
//                    .font(.title2)
//                    .foregroundColor(.white.opacity(chevronOpacity))
//                    .padding(.top, 8)
//                    .onAppear {
//                        withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
//                            chevronOpacity = 1.0
//                        }
//                    }

                Spacer().frame(height: 4)
            }
        }
    }
}

// ─────────────────────────────────────────────
// MARK: - Mascot Duck
// ─────────────────────────────────────────────
struct MascotDuckView: View {
    @State private var eyeOffset: CGSize = .zero
    @State private var blinkScale: CGFloat = 1.0
 
    private let wingColor = Color(red: 0.94, green: 0.74, blue: 0.10)
    private let billColor  = Color(red: 1.00, green: 0.52, blue: 0.12)
    private let pupilColor = Color(red: 0.10, green: 0.08, blue: 0.12)
 
    var body: some View {
        ZStack {
            // ── Ground shadow ──
            Ellipse()
                .fill(Color.black.opacity(0.09))
                .frame(width: 68, height: 12)
                .offset(y: 55)
            // ── Wings ──
            Ellipse()
                            .fill(wingColor)
                            .frame(width: 38, height: 22)
                            .rotationEffect(.degrees(-30))
                            .offset(x: -44, y: 8)
                        Ellipse()
                            .fill(wingColor)
                            .frame(width: 38, height: 22)
                            .rotationEffect(.degrees(30))
                            .offset(x:  44, y: 8)
 
            // ── Body ──
            Circle()
                .fill(Color.sunYellow)
                .frame(width: 80, height: 90)
                .offset(y: 10)
 
            
                            
 
            // ── Head  (center at y: -40) ──
            Ellipse()
                .fill(Color.sunYellow)
                .frame(width: 96, height: 89)
                .offset(y: -40)
 
            // ── Head tuft (3 blobs above head top ≈ y: -76) ──
            Circle().fill(wingColor).frame(width: 10, height: 15).offset(x: -8,  y: -80)
            Circle().fill(wingColor).frame(width: 13, height: 18).offset(x:  0,  y: -84)
            Circle().fill(wingColor).frame(width: 10, height: 15).offset(x:  8,  y: -80)
  
            // ── Blush — big soft ovals on cheeks of head ──
            // Head cheeks are around y: -36, x: ±28
            Circle()
                .fill(Color.peach.opacity(0.55))
                .frame(width: 28, height: 28)
                .offset(x: -32, y: -28)
            Circle()
                .fill(Color.peach.opacity(0.55))
                .frame(width: 28, height: 28)
                .offset(x:  32, y: -28)
 
            // ── Eyes — oval black, no white ring, on upper face ──
            // Head center y: -40. Eyes sit at y: -44 (upper face).
            Ellipse()
                .fill(pupilColor)
                .frame(width: 11, height: 16)
                .scaleEffect(x: 1.0, y: blinkScale, anchor: .center)
                .offset(x: -19 + eyeOffset.width, y: -40 + eyeOffset.height)
            Ellipse()
                .fill(pupilColor)
                .frame(width: 11, height: 16)
                .scaleEffect(x: 1.0, y: blinkScale, anchor: .center)
                .offset(x:  19 + eyeOffset.width, y: -40 + eyeOffset.height)
 
            // ── Tiny shine dot (gives eyes life) ──
            Circle()
                .fill(Color.white.opacity(0.75))
                .frame(width: 3.5, height: 3.5)
                .scaleEffect(x: 1.0, y: blinkScale, anchor: .center)
                .offset(x: -17 + eyeOffset.width, y: -44 + eyeOffset.height)
            Circle()
                .fill(Color.white.opacity(0.75))
                .frame(width: 3.5, height: 3.5)
                .scaleEffect(x: 1.0, y: blinkScale, anchor: .center)
                .offset(x:  21 + eyeOffset.width, y: -44 + eyeOffset.height)
 
            // ── Bill — flat duck bill, lower face ──
            // Lower face of head: y: -40 + ~14 = -26
            Ellipse()
                .fill(billColor)
                .frame(width: 26, height: 17)
                .offset(y: -32)
            Capsule()
                .fill(Color(red: 0.80, green: 0.36, blue: 0.08).opacity(0.35))
                .frame(width: 17, height: 1.6)
                .offset(y: -28)
 
            // ── Feet ──
            
            Ellipse()
                            .fill(billColor)
                            .frame(width: 28, height: 14)
                            .offset(x: -16, y: 50)
                        Ellipse()
                            .fill(billColor)
                            .frame(width: 28, height: 14)
                            .offset(x:  16, y: 50)
        }
        .onAppear { scheduleBlink(); scheduleLook() }
    }
 
    private func scheduleBlink() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int.random(in: 2800...4500))) {
            withAnimation(.easeIn(duration: 0.07))  { blinkScale = 0.08 }
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(130)) {
                withAnimation(.easeOut(duration: 0.09)) { blinkScale = 1.0 }
                scheduleBlink()
            }
        }
    }
 
    private func scheduleLook() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int.random(in: 3500...6000))) {
            let dirs: [CGSize] = [
                .init(width: -3.5, height: 0),   .init(width: 3.5, height: 0),
                .init(width: 0,   height: -2.5),  .init(width: 2.5, height: 2.0),
                .init(width: -2.0, height: 2.0),  .init(width: 3.0, height: -1.5),
            ]
            withAnimation(.easeInOut(duration: 0.22)) { eyeOffset = dirs.randomElement()! }
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int.random(in: 600...1400))) {
                withAnimation(.easeInOut(duration: 0.20)) { eyeOffset = .zero }
                scheduleLook()
            }
        }
    }
}
 
private struct DuckFoot: View {
    private let c = Color(red: 1, green: 0.52, blue: 0.12)
    var body: some View {
        ZStack {
            Capsule().fill(c).frame(width: 11, height: 4).rotationEffect(.degrees(-22)).offset(x: -4)
            Capsule().fill(c).frame(width: 11, height: 4)
            Capsule().fill(c).frame(width: 11, height: 4).rotationEffect(.degrees(22)).offset(x: 4)
        }
    }
}

// ─────────────────────────────────────────────
// MARK: - Clean Letter Card
// ─────────────────────────────────────────────
struct CleanLetterCard: View {
    @Binding var title: String
    @Binding var content: String
    @FocusState private var focusedField: CardField?
    enum CardField { case title, content }

    var body: some View {
        ZStack(alignment: .topLeading) {

            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.72, green: 0.66, blue: 0.50))
                .offset(x: 3, y: 7)
                .allowsHitTesting(false)

            RoundedRectangle(cornerRadius: 12)
                .fill(Color.paperCream)
                .allowsHitTesting(false)

            Rectangle()
                .fill(Color.peach.opacity(0.50))
                .frame(width: 1.5)
                .padding(.leading, 54)
                .clipShape(RoundedRectangle(cornerRadius: 22))
                .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: 0) {

                HStack(alignment: .top) {
                    Spacer()
                    Text(Date(), style: .date)
                        .font(.system(.caption2, design: .rounded))
                        .foregroundColor(.inkColor.opacity(0.28))
                        .padding(.top, 18)
                    StampDecoration().padding(.trailing, 6)
                }
                .padding(.trailing, 16)

                Text("Dear Future Me,")
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundColor(.inkColor.opacity(0.80))
                    .padding(.leading, 66)
                    .padding(.trailing, 20)
                    .padding(.top, 6)
                    .padding(.bottom, 4)

                TextField("Give your letter a title…", text: $title)
                    .font(.system(.title3, design: .rounded).weight(.bold))
                    .foregroundColor(.inkColor)
                    .focused($focusedField, equals: .title)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .content }
                    .padding(.leading, 66)
                    .padding(.trailing, 20)

                Rectangle()
                    .fill(Color.inkColor.opacity(0.07))
                    .frame(height: 1)
                    .padding(.leading, 66)
                    .padding(.trailing, 20)
                    .padding(.vertical, 8)

                ZStack(alignment: .topLeading) {
                    if content.isEmpty {
                        Text("Write anything — hopes, gratitude,\ngoals, fears. Your future self will read this.")
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(.inkColor.opacity(0.22))
                            .padding(.leading, 66)
                            .padding(.trailing, 20)
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
                        .padding(.trailing, 16)
                        .padding(.bottom, 16)
                        .frame(minHeight: 180)
                }
            }
        }
        .shadow(color: .black.opacity(0.10), radius: 14, y: 6)
        .onTapGesture {
            if focusedField == nil { focusedField = title.isEmpty ? .title : .content }
        }
    }
}

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

// ─────────────────────────────────────────────
// MARK: - Ducky Profile (3rd tab)
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
        switch totalLetters {
        case 0:  return "Every journey starts with one letter.\nWrite your first one! 💌"
        case 1:  return "You've started something beautiful.\nKeep writing to your future self! 🌟"
        default: return "Your future self has \(totalLetters) letters waiting.\nThey'll be so happy to read them! ✨"
        }
    }

    var body: some View {
        ZStack {
            Color.skyBright.ignoresSafeArea()
            CloudView(scale: 0.85, opacity: 1.0).position(x: 70,  y: 120)
            CloudView(scale: 0.60, opacity: 1.0).position(x: 310, y: 170)

            VStack(spacing: 28) {
                Spacer()

                MascotDuckView()
                    .frame(width: 150, height: 160)
                    .scaleEffect(1.15)
                    .offset(y: bobOffset)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                            bobOffset = -8
                        }
                    }

                Text("Hi, I'm Terry!")
                    .font(.system(.title, design: .rounded).weight(.heavy))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.08), radius: 4, y: 2)

                HStack(spacing: 16) {
                    DuckyStatCard(number: "\(totalLetters)", label: "Letters\nSent",    icon: "envelope.fill")
                    DuckyStatCard(number: totalLetters > 0 ? "\(daysSinceFirst)" : "—",
                                  label: "Days\nWriting", icon: "calendar.badge.clock")
                }
                .padding(.horizontal, 40)

                Text(encouragementText)
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.white.opacity(0.92))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 18)
                    .background(RoundedRectangle(cornerRadius: 18).fill(Color.white.opacity(0.18)))
                    .padding(.horizontal, 32)

                Spacer()
                Spacer()
            }
        }
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
                .font(.system(.title, design: .rounded).weight(.heavy))
                .foregroundColor(.white)
            Text(label)
                .font(.system(.caption, design: .rounded).weight(.semibold))
                .foregroundColor(.white.opacity(0.72))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 22)
        .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.18)))
    }
}

// ─────────────────────────────────────────────
// MARK: - Bird silhouette (tiny V in the sky)
// ─────────────────────────────────────────────
struct BirdSilhouette: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.midY))
        p.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.maxY),
                       control: CGPoint(x: rect.width * 0.25, y: rect.minY))
        p.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.midY),
                       control: CGPoint(x: rect.width * 0.75, y: rect.minY))
        return p
    }
}



#Preview {
    ContentView()
        .modelContainer(for: Letter.self, inMemory: true)
}



