import SwiftUI
import CoreMotion



private enum FoldAxis { case right, down, inward }

private func foldAxis(for step: Int) -> FoldAxis {
    switch step {
    case 0: return .right
    case 1: return .inward
    case 2: return .down
    case 3: return .inward
    case 4: return .right
    case 5: return .down
    case 6: return .right
    case 7: return .down
    default: return .right
    }
}

struct RitualView: View {
    let envelopeColorIndex: Int
    var onComplete: () -> Void
    var onCancel: () -> Void

    @State private var showExitSheet = false

    @State private var haptics       = PaperFoldHaptics()
    @State private var dragProgress:   CGFloat = 0
    @State private var isDragging    = false
 
    @State private var foldStep      = 0
    @State private var planeOffset   = CGSize.zero
    @State private var planeRotation: Double = 0
    @State private var planeLift:     Double = 0
    @State private var showSkyScene  = false
    @State private var paperScale:   CGFloat = 1.0
 
    // Motion
    private let motionManager = CMMotionManager()
    @State private var readyToLaunch = false
    @State private var hasLaunched   = false
 
    private var accentColor: Color { EnvelopePalette.main(envelopeColorIndex) }
    private var lightColor:  Color { EnvelopePalette.light(envelopeColorIndex) }

    var body: some View {
        ZStack {
            Group {
                if showSkyScene { SkyBackground() } else { TableBackground() }
            }
            .animation(.easeInOut(duration: 0.7), value: showSkyScene)

            VStack(spacing: 0) {
                // Top bar
                HStack {
                    if !showSkyScene {
                        Button { onCancel() } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.coral)
                        }
                    }
                    
                    Spacer()
                    if !showSkyScene {
                        StepDots(currentStep: foldStep, totalSteps: 9)
                    }
                    Spacer()
                    if !showSkyScene {
                            Button {
                                foldStep = 8
                                    hasLaunched = true
                                    
                                    // Instantly show sky and launch
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        triggerLaunchSequence()
                                }
                            } label: {
                                Text("Skip")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(.inkColor.opacity(0.32))
                            }
                        } else {
                            Text("Skip").font(.system(size: 14)).opacity(0)
                        }
                }
                .padding(.horizontal, 28)
                .padding(.top, 20)

                // Instruction label
                if !showSkyScene {
                    Text(instructionText)
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(showSkyScene ? .white : .inkColor)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 36)
                        .padding(.top, 28)
//                        .id(foldStep)
//                        .transition(.asymmetric(
//                            insertion: .opacity.combined(with: .offset(y: 10)),
//                            removal:   .opacity.combined(with: .offset(y: -10))
//                        ))
//                        .animation(.easeInOut(duration: 0.3), value: foldStep)
                }

                Spacer()

                if foldStep < 8 { foldingScene } else { launchScene }

                Spacer()
 
                // Bottom hint
                HStack(spacing: 6) {
                                    Image(systemName: foldStep >= 8
                                          ? (showSkyScene ? "paperplane.fill" : "iphone.and.arrow.forward")
                                          : gestureHintIcon)
                                        .font(.subheadline)
                                    Text(foldStep >= 8
                                         ? (showSkyScene ? "Watch it go…" : "Move your phone forward to launch")
                                         : gestureHintText)
                                        .font(.system(.subheadline, design: .rounded))
                                }
                                .foregroundColor(showSkyScene ? .white.opacity(0.72) : .inkColor.opacity(0.38))
                                .padding(.bottom, 52)
//                                .animation(.easeInOut(duration: 0.4), value: showSkyScene)
                .foregroundColor(showSkyScene ? .white.opacity(0.72) : .inkColor.opacity(0.38))
                .padding(.bottom, 52)
            }
        }
//        .onAppear {
//            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
//                planeLift = -7
//            }
//        }
        .onChange(of: foldStep) { oldValue, newValue in
            if newValue == 8 {
                // As soon as the last fold is done, we prep for launch
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    readyToLaunch = true
                    startMotionDetection()
                }
            }
        }
        
    }

    // MARK: - Paper styling helpers

    var paperFill = Color.paperCream.opacity(1.0)

    var outlineColor = Color.inkColor.opacity(0.0)

    var outlineWidth = CGFloat(1)

    private var paperBody: some View {
        let base = FoldingPaper(step: foldStep)
            .fill(paperFill) // This now fills the body AND the wing as one piece
            .frame(width: 200, height: 240)

        let withCreases = base.overlay(
            CompletedCreaseLines(step: foldStep)
                .frame(width: 200, height: 240)
        )

        // Add back your outline and arrows
        return withCreases
            .overlay(
                        FoldCreaseLine(step: foldStep)
                            .stroke(
                                Color.gardenGreen
                                .opacity(0.8), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                            .frame(width: 200, height: 240)
                    )
            .overlay(
                FoldingPaper(step: foldStep)
                    .stroke(outlineColor, lineWidth: outlineWidth)
            )
            .overlay(
                FoldArrow(step: foldStep, accentColor: accentColor)
                    .frame(width: 200, height: 240)
            )
//            .shadow(color: .black.opacity(0.12), radius: 16, y: 10) // One shadow for the whole plane!
    }

    // MARK: - Folding scene

    private var foldingScene: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.tableWarm.opacity(0.50))
                .frame(width: 295, height: 350)
//                .shadow(color: .black.opacity(0.06), radius: 14, y: 6)

//            FoldingPaper(step: foldStep)
//                .fill(Color.black.opacity(0.07))
//                .frame(width: 200, height: 240)
//                .offset(x: 4, y: 9)
////                .blur(radius: CGFloat(foldStep) * 1.2 + 2)

            paperBody
        }
        .contentShape(Rectangle())
        .gesture(foldDragGesture)
        .onTapGesture { advanceFold() }
    }

    private var rotationBias: Double {
        switch foldAxis(for: foldStep) {
        case .right:  return 3.0
        case .inward: return 0.0
        case .down:   return 0.0
        }
    }

    // MARK: - Directional drag gesture

    private var foldDragGesture: some Gesture {
        DragGesture(minimumDistance: 8)
            .onChanged { v in
                if !isDragging {
                    isDragging = true
                    haptics.paperTouch()
                }
                let raw: CGFloat
                switch foldAxis(for: foldStep) {
                case .right:  raw = v.translation.width
                case .down:   raw = v.translation.height
                case .inward: raw = abs(v.translation.width)
                }
                let prev = dragProgress
                dragProgress = max(0, min(1, raw / 90))
                if prev < 0.50 && dragProgress >= 0.50 { haptics.resistanceTick() }
                if prev < 0.85 && dragProgress >= 0.85 { haptics.resistanceTick() }
            }
            .onEnded { _ in
                isDragging = false
                if dragProgress > 0.75 { advanceFold() }
                withAnimation(.spring(response: 0.30, dampingFraction: 0.70)) {
                    dragProgress = 0
                }
            }
    }

    // MARK: - Launch scene

    private var launchScene: some View {
            ZStack {
                // Sparkle dots that follow the plane
                ForEach(0..<6, id: \.self) { i in
                    let sizes: [CGFloat] = [6, 4, 8, 5, 7, 4]
                    let xs: [CGFloat]    = [-65, 55, -35, 75, -85, 40]
                    let ys: [CGFloat]    = [-45, -75, -110, -55, -88, -118]
                    Circle()
                        .fill(accentColor.opacity(hasLaunched ? 0.75 : 0))
                        .frame(width: sizes[i], height: sizes[i])
                        .offset(x: xs[i], y: ys[i])
                        .offset(planeOffset)
                        .animation(
                            .interpolatingSpring(stiffness: 38, damping: 9)
                                .delay(Double(i) * 0.04),
                            value: planeOffset
                        )
                }
     
                // ── The actual paper plane (your FoldingPaper shape, not SF Symbol) ──
                ZStack {
                    // Shadow layer
                    FoldingPaper(step: 8)
                        .fill(Color.black.opacity(0.10))
                        .frame(width: 148, height: 108)
                        .offset(x: 5, y: 8)
                        .blur(radius: 6)
     
                    // Body
                    FoldingPaper(step: 8)
                        .fill(Color.paperCream)
                        .frame(width: 200, height: 200)
                        .overlay(
                            FoldingPaper(step: 8)
                                .stroke(accentColor.opacity(0.40), lineWidth: 1.2)
                                .frame(width: 200, height: 200)
                        )
                        // Crease lines from the folding
                        .overlay(
                            CompletedCreaseLines(step: 8)
                                .frame(width: 200, height: 200)
                        )
                }
                .rotationEffect(.degrees(planeRotation))
                .offset(planeOffset)
                .offset(y: planeLift)
                // Pulse ring — only visible before launch, hints "it's ready"
                .overlay(
                    Circle()
                        .strokeBorder(accentColor.opacity(readyToLaunch && !hasLaunched ? 0.28 : 0),
                                      lineWidth: 1.5)
                        .frame(width: 140, height: 140)
                        .scaleEffect(readyToLaunch && !hasLaunched ? 1.0 : 0.7)
                        .animation(
                            .easeInOut(duration: 1.1).repeatForever(autoreverses: true),
                            value: readyToLaunch
                        )
                )
            }
            .onAppear {
                // Brief pause so the fold-complete haptic settles, then arm motion
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    withAnimation { readyToLaunch = true }
                    startMotionDetection()
                }
            }
        }

    // MARK: - Actions

    private func advanceFold() {
            guard foldStep < 8 else { return }
            haptics.creaseSnap(step: foldStep)
            withAnimation(.spring(response: 0.14, dampingFraction: 0.38)) { paperScale = 0.91 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.13) {
                withAnimation(.spring(response: 0.42, dampingFraction: 0.55)) { paperScale = 1.0 }
            }
            withAnimation(.spring(response: 0.50, dampingFraction: 0.62)) { foldStep += 1 }
            if foldStep == 8 { haptics.finalFold() }
        }
     

    private func launchPlane(translation: CGSize) {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        withAnimation(.interpolatingSpring(stiffness: 36, damping: 8)) {
            planeOffset   = CGSize(width: translation.width * 4.0, height: -1500)
            planeRotation = Double(translation.width) * 0.35 - 10
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.80) { onComplete() }
    }
    
    private func startMotionDetection() {
        guard motionManager.isAccelerometerAvailable, !hasLaunched else {
            print("❌ Accelerometer not available or already launched")
            return
        }
        motionManager.accelerometerUpdateInterval = 0.016
        motionManager.startAccelerometerUpdates(to: .main) { data, error in
            if let error {
                print("❌ Motion error: \(error)")
                return
            }
            guard let data else {
                print("❌ No data")
                return
            }

            let x = data.acceleration.x
            let y = data.acceleration.y
            let z = data.acceleration.z
            let magnitude = sqrt(x*x + y*y + z*z)
            print("📱 magnitude: \(magnitude)")

            guard self.readyToLaunch, !self.hasLaunched else { return }
            if magnitude > 1.8 {
                self.motionManager.stopAccelerometerUpdates()
                self.triggerLaunchSequence()
            }
        }
    }
    private func triggerLaunchSequence() {
        hasLaunched = true

        // Step 1: nose dips — same
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.55)) {
            planeRotation = -18
        }

        // Step 2: sky fades in — was 0.20s, now 0.4s
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeInOut(duration: 1.4)) {   // was 0.9
                showSkyScene = true
            }
        }

        // Step 3: plane flies — was 0.45s, now 0.9s
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            withAnimation(.interpolatingSpring(stiffness: 18, damping: 10)) {  // was stiffness 36
                planeOffset   = CGSize(width: 30, height: -1400)
                planeRotation = -20
            }
        }

        // Step 4: close — was 1.3s, now 2.8s
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
            onComplete()
        }
    }
     
    // MARK: - Text (9 steps: 0 → 8)

    private var instructionText: String {
        switch foldStep {
        case 0: return "Your letter is ready. \nFold it in half lengthwise"
        case 1: return "Now unfold it back open\nto reveal the center crease"
        case 2: return "Fold both top corners\ndown to the center crease"
        case 3: return "Fold both slanted edges\nin to meet the center spine"
        case 4: return "Fold the whole thing\nin half along the spine"
        case 5: return "Fold the top wing down\nflush with the bottom edge."
        case 6: return "Flip the plane over\nto the other side"
        case 7: return "Fold this wing down\nto match the other side"
        case 8: return "Hold your phone up\nand throw it forward"
        
        

        default: return ""
        }
    }

    private var gestureHintText: String {
        switch foldStep {
        case 0: return "Swipe right"
        case 1: return "Swipe left"
        case 2: return "Swipe down"
        case 3: return "Swipe inward from both sides"
        case 4: return "Swipe right"
        case 5: return "Swipe down"
        case 6: return "Swipe right"
        case 7: return "Swipe down"
        case 8: return "Move your phone forward"
        default: return ""
        }
    }

    private var gestureHintIcon: String {
        switch foldStep {
        case 1: return "arrow.left"
        case 0, 4, 6: return "arrow.right"
        case 2, 5, 7: return "arrow.down"
        default: return ""
        }
    }
}




#Preview {
    RitualView(envelopeColorIndex: 0, onComplete: {},
               onCancel:   {})
     
}


