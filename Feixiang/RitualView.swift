import SwiftUI

struct RitualView: View {
    let envelopeColorIndex: Int
    var onComplete: () -> Void
    var onCancel: () -> Void

    @State private var foldStep = 0
    @State private var planeOffset   = CGSize.zero
    @State private var planeRotation: Double = 0
    @State private var planeLift: Double = 0
    @State private var showSkyScene  = false
    @State private var paperScale: CGFloat = 1.0

    private var accentColor: Color { EnvelopePalette.main(envelopeColorIndex) }
    private var lightColor:  Color { EnvelopePalette.light(envelopeColorIndex) }

    var body: some View {
        ZStack {
            // Background
            Group {
                if showSkyScene { SkyBackground() } else { TableBackground() }
            }
            .animation(.easeInOut(duration: 0.7), value: showSkyScene)

            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Button { onCancel() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(showSkyScene ? .white.opacity(0.72) : .inkColor.opacity(0.32))
                    }
                    Spacer()
                    if !showSkyScene {
                        StepDots(currentStep: foldStep, totalSteps: 5)
                    }
                    Spacer()
                    // Balance spacer
                    Image(systemName: "xmark.circle.fill").font(.title2).opacity(0)
                }
                .padding(.horizontal, 28)
                .padding(.top, 20)

                // Instruction
                Text(instructionText)
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(showSkyScene ? .white : .inkColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 36)
                    .padding(.top, 28)
                    .id(foldStep)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .offset(y: 10)),
                        removal:   .opacity.combined(with: .offset(y: -10))
                    ))
                    .animation(.easeInOut(duration: 0.3), value: foldStep)

                Spacer()

                if !showSkyScene {
                    foldingScene
                } else {
                    launchScene
                }

                Spacer()

                // Bottom hint
                HStack(spacing: 6) {
                    Image(systemName: showSkyScene ? "arrow.up.circle.fill" : "hand.tap.fill")
                        .font(.subheadline)
                    Text(showSkyScene
                         ? "Drag the plane upward to release"
                         : (foldStep < 4 ? "Tap to fold" : "One last tap to finish!"))
                        .font(.system(.subheadline, design: .rounded))
                }
                .foregroundColor(showSkyScene ? .white.opacity(0.72) : .inkColor.opacity(0.38))
                .padding(.bottom, 52)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                planeLift = -7
            }
        }
    }

    // MARK: - Folding scene (table)

    private var foldingScene: some View {
        ZStack {
            // Table surface
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.tableWarm.opacity(0.50))
                .frame(width: 295, height: 350)
                .shadow(color: .black.opacity(0.06), radius: 14, y: 6)

            // Paper drop shadow — softens as we fold
            FoldingPaper(step: foldStep)
                .fill(Color.black.opacity(0.07))
                .frame(width: 200, height: 240)
                .offset(x: 4, y: 9)
                .blur(radius: CGFloat(foldStep) * 1.5 + 2)

            // Envelope / paper body — tinted with chosen color on step 0
            FoldingPaper(step: foldStep)
                .fill(foldStep == 0 ? lightColor.opacity(0.55) : Color.paperCream)
                .frame(width: 200, height: 240)
                .overlay(
                    // Flap accent color on step 0
                    Group {
                        if foldStep == 0 {
                            EnvelopeFlapOverlay()
                                .fill(accentColor.opacity(0.38))
                                .frame(width: 200, height: 240)
                        }
                    }
                )
                .overlay(
                    FoldCreaseLine(step: foldStep)
                        .stroke(
                            Color.inkColor.opacity(0.14),
                            style: StrokeStyle(lineWidth: 1.3, dash: [5, 3])
                        )
                        .frame(width: 200, height: 240)
                )
                .overlay(
                    FoldingPaper(step: foldStep)
                        .stroke(
                            foldStep == 0 ? accentColor.opacity(0.45) : Color.inkColor.opacity(0.07),
                            lineWidth: foldStep == 0 ? 1.8 : 1.0
                        )
                )
                .scaleEffect(paperScale)
                .shadow(color: .black.opacity(0.12), radius: 16, y: 10)
                .animation(.spring(response: 0.50, dampingFraction: 0.62), value: foldStep)
        }
        .onTapGesture { advanceFold() }
    }

    // MARK: - Launch scene (sky)

    private var launchScene: some View {
        ZStack {
            // Sparkle particles
            ForEach(0..<6, id: \.self) { i in
                let sizes: [CGFloat] = [6, 4, 8, 5, 7, 4]
                let xs: [CGFloat]    = [-65, 55, -35, 75, -85, 40]
                let ys: [CGFloat]    = [-45, -75, -110, -55, -88, -118]
                Circle()
                    .fill(Color.sunYellow.opacity(0.75))
                    .frame(width: sizes[i], height: sizes[i])
                    .offset(x: xs[i], y: ys[i])
                    .offset(planeOffset)
                    .animation(
                        .interpolatingSpring(stiffness: 38, damping: 9).delay(Double(i) * 0.04),
                        value: planeOffset
                    )
            }

            Image(systemName: "paperplane.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 108, height: 108)
                .foregroundColor(.white)
                .shadow(color: .white.opacity(0.55), radius: 18)
                .rotationEffect(.degrees(planeRotation - 45))
                .offset(planeOffset)
                .offset(y: planeLift)
                .gesture(
                    DragGesture()
                        .onChanged { v in
                            withAnimation(.interactiveSpring()) {
                                planeOffset  = v.translation
                                planeRotation = Double(v.translation.width) * 0.22
                            }
                        }
                        .onEnded { g in
                            if g.translation.height < -80 {
                                launchPlane(translation: g.translation)
                            } else {
                                withAnimation(.spring(response: 0.42, dampingFraction: 0.65)) {
                                    planeOffset   = .zero
                                    planeRotation = 0
                                }
                            }
                        }
                )
        }
    }

    // MARK: - Actions

    private func advanceFold() {
        let styles: [UIImpactFeedbackGenerator.FeedbackStyle] = [.light, .light, .medium, .medium, .heavy]
        UIImpactFeedbackGenerator(style: styles[min(foldStep, styles.count-1)]).impactOccurred()

        // Crease-snap pulse
        withAnimation(.spring(response: 0.14, dampingFraction: 0.4)) { paperScale = 0.92 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            withAnimation(.spring(response: 0.36, dampingFraction: 0.55)) { paperScale = 1.0 }
        }

        if foldStep < 4 {
            withAnimation(.spring(response: 0.50, dampingFraction: 0.62)) { foldStep += 1 }
        } else {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            withAnimation(.easeInOut(duration: 0.65)) { showSkyScene = true }
        }
    }

    private func launchPlane(translation: CGSize) {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        withAnimation(.interpolatingSpring(stiffness: 36, damping: 8)) {
            planeOffset   = CGSize(width: translation.width * 4.0, height: -1500)
            planeRotation = Double(translation.width) * 0.35 - 10
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.80) { onComplete() }
    }

    private var instructionText: String {
        switch foldStep {
        case 0: return "Your letter is sealed ✉️\nNow let's fold it into a plane"
        case 1: return "Fold in half lengthwise 📄"
        case 2: return "Fold the top corners to the center ✂️"
        case 3: return "Fold the nose tip back 👇"
        case 4: return "Fold the wings down ✈️"
        default: return "Your plane is ready 💌\nFlick it into the sky!"
        }
    }
}

// MARK: - Envelope flap overlay (colored flap on step 0)

struct EnvelopeFlapOverlay: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        path.move(to: CGPoint(x: 0, y: h * 0.28))
        path.addLine(to: CGPoint(x: w * 0.5, y: 0))
        path.addLine(to: CGPoint(x: w, y: h * 0.28))
        path.closeSubpath()
        return path
    }
}

// MARK: - Step dots

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
