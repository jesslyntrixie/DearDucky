import SwiftUI

// MARK: - Fold gesture axis per step
// Step 0: crease lengthwise        → swipe RIGHT
// Step 1: unfold it back           → swipe INWARD (spread open)
// Step 2: top corners down         → swipe DOWN
// Step 3: diagonal edges to center → swipe INWARD
// Step 4: fold body in half        → swipe RIGHT
// Step 5: fold first wing down     → swipe DOWN
// Step 6: flip the plane           → swipe RIGHT
// Step 7: fold second wing down    → swipe DOWN
// (Step 8 = done → launch scene)
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

    @State private var haptics      = PaperFoldHaptics()
    @State private var dragProgress: CGFloat = 0
    @State private var isDragging   = false

    @State private var foldStep     = 8
    @State private var planeOffset  = CGSize.zero
    @State private var planeRotation: Double = 0
    @State private var planeLift: Double = 0
    @State private var showSkyScene = false
    @State private var paperScale: CGFloat = 1.0

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
                    Button { onCancel() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(showSkyScene ? .white.opacity(0.72) : .inkColor.opacity(0.32))
                    }
                    Spacer()
                    if !showSkyScene {
                        StepDots(currentStep: foldStep, totalSteps: 9)
                    }
                    Spacer()
                    Image(systemName: "xmark.circle.fill").font(.title2).opacity(0)
                }
                .padding(.horizontal, 28)
                .padding(.top, 20)

                // Instruction label
                Text(instructionText)
                    .font(.system(.title3, design: .rounded))
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

                if !showSkyScene { foldingScene } else { launchScene }

                Spacer()

                // Bottom hint
                HStack(spacing: 6) {
                    Image(systemName: showSkyScene ? "arrow.up.circle.fill" : gestureHintIcon)
                        .font(.subheadline)
                    Text(showSkyScene ? "Drag the plane upward to release" : gestureHintText)
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
                FoldArrowOverlay(step: foldStep, accentColor: accentColor)
                    .frame(width: 200, height: 240)
            )
            .shadow(color: .black.opacity(0.12), radius: 16, y: 10) // One shadow for the whole plane!
    }

    // MARK: - Folding scene

    private var foldingScene: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.tableWarm.opacity(0.50))
                .frame(width: 295, height: 350)
                .shadow(color: .black.opacity(0.06), radius: 14, y: 6)

            FoldingPaper(step: foldStep)
                .fill(Color.black.opacity(0.07))
                .frame(width: 200, height: 240)
                .offset(x: 4, y: 9)
                .blur(radius: CGFloat(foldStep) * 1.2 + 2)

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
                                planeOffset   = v.translation
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
        if foldStep < 8 {
            haptics.creaseSnap(step: foldStep)
            withAnimation(.spring(response: 0.14, dampingFraction: 0.38)) { paperScale = 0.91 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.13) {
                withAnimation(.spring(response: 0.42, dampingFraction: 0.55)) { paperScale = 1.0 }
            }
            withAnimation(.spring(response: 0.50, dampingFraction: 0.62)) { foldStep += 1 }
        } else {
            haptics.finalFold()
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

    // MARK: - Text (9 steps: 0 → 8)

    private var instructionText: String {
        switch foldStep {
        case 0: return "Your letter is ready ✉️\nFold it in half lengthwise"
        case 1: return "Now unfold it back open\nto reveal the center crease"
        case 2: return "Fold both top corners\ndown to the center crease"
        case 3: return "Fold both slanted edges\nin to meet the center spine"
        case 4: return "Fold the whole thing\nin half along the spine"
        case 5: return "Fold the top wing down\nflush with the bottom edge ✈️"
        case 6: return "Flip the plane over\nto the other side"
        case 7: return "Fold this wing down too\nto match the other side"
        case 8: return "Your plane is ready 💌\nFlick it into the sky!"
        default: return ""
        }
    }

    private var gestureHintText: String {
        switch foldStep {
        case 0: return "Swipe right to crease"
        case 1: return "Swipe outward to unfold"
        case 2: return "Swipe down to fold corners"
        case 3: return "Swipe inward from both sides"
        case 4: return "Swipe right to fold body"
        case 5: return "Swipe down to fold wing"
        case 6: return "Swipe right to flip over"
        case 7: return "Swipe down to fold wing"
        case 8: return "Tap to launch!"
        default: return ""
        }
    }

    private var gestureHintIcon: String {
        switch foldStep {
        case 1: return "arrow.left"
        case 0, 4, 6: return "arrow.right"
        case 3:    return "arrow.left.and.right"
        case 2, 5, 7: return "arrow.down"
        default:      return "hand.tap.fill"
        }
    }
}

// MARK: - CompletedCreaseLines
// Soft solid lines showing every fold that has already been made.
// Just a gentle inkColor line — flat, clean, no shadows.

struct CompletedCreaseLines: View {
    let step: Int

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let mx = w / 2

            ZStack {
                switch step {
                case 0:
                    // No folds have been completed yet
                    EmptyView()

                case 1:
                    // You just finished the lengthwise fold
                    // (But you said you wanted this empty/removed earlier!)
                    EmptyView()

                case 2:
                    // Only show the spine if you want it here
                    spine(mx: mx, h: h)

                case 3:
                    spine(mx: mx, h: h)
                    shoulderLine(w: w, h: h)

                case 4:
                    spine(mx: mx, h: h)
                    horizontalLine(w: w, h: h, ratio: 0.80)
                    
                case 6:
                    let sy = h * 0.80
                    let foldAnchorX = w * 0.80
                    
                    
                        line(from: .init(x: mx, y: 0),
                             to:   .init(x: foldAnchorX, y: h))
                        line(from: .init(x:mx, y: h * 0.91), to: .init(x: w * 0.65, y: h))
                        
                    
                case 7:
                    let sy = h * 0.80
                    
                    line(from: .init(x:w*0.20, y: h), to: .init(x: w*0.35, y: h))
                    
                case 8:
                    let sy = h * 0.80
                    let midY = (sy + h) / 2
                    let extensionX = mx + (w - mx)
                    let foldAnchorX = w * 0.80
                    line(from: .init(x:mx, y: 10), to: .init(x: w*0.42, y: h*0.86))
                    line(from: .init(x:mx, y: 10), to: .init(x: w*0.58, y: h*0.86))
                    
                    
                
 
                default:
                    EmptyView()
                }
            }
        }
    }

    // MARK: - Helper Drawing Functions\
    
    private func shoulderLine(w: CGFloat, h: CGFloat) -> some View {
        let sy = h * 0.44 // The shoulder height
        
        // Draw from the very left (0) to the very right (w)
        return line(from: .init(x: 0, y: sy),
                    to:   .init(x: w, y: sy))
    }
    
    private func spine(mx: CGFloat, h: CGFloat) -> some View {
        line(from: .init(x: mx, y: 0), to: .init(x: mx, y: h))
    }

    private func roofDiagonals(mx: CGFloat, w: CGFloat, h: CGFloat) -> some View {
        Group {
            let px = mx - w * 0.25
            line(from: .init(x: px, y: 0), to: .init(x: mx, y: h * 0.44))
            line(from: .init(x: px + w * 0.5, y: 0), to: .init(x: mx, y: h * 0.44))
        }
    }

    private func innerDiagonals(mx: CGFloat, w: CGFloat, h: CGFloat) -> some View {
        Group {
            let px = mx - w * 0.25
            let sy = h * 0.44
            line(from: .init(x: px, y: sy), to: .init(x: mx, y: h * 0.90))
            line(from: .init(x: px + w * 0.5, y: sy), to: .init(x: mx, y: h * 0.90))
        }
    }

    private func wingCreases(mx: CGFloat, w: CGFloat, h: CGFloat, step: Int) -> some View {
        Group {
            if step >= 6 {
                let px = mx - w * 0.10
                line(from: .init(x: px, y: h * 0.38), to: .init(x: px + w * 0.20, y: h * 0.38))
            }
        }
    }

    private func line(from a: CGPoint, to b: CGPoint) -> some View {
        Path { p in p.move(to: a); p.addLine(to: b) }
            .stroke(Color.inkColor.opacity(0.18), style: StrokeStyle(lineWidth: 1.0, lineCap: .round))
    }
    
    private func horizontalLine(w: CGFloat, h: CGFloat, ratio: CGFloat) -> some View {
        let yPosition = h * ratio
        return line(from: .init(x: 0, y: yPosition),
                    to:   .init(x: w, y: yPosition))
    }
}

// MARK: - FoldArrowOverlay
// Animated directional arrows rendered ON the paper to show where / which way to fold.

struct FoldArrowOverlay: View {
    let step: Int
    let accentColor: Color
    @State private var pulse = false

    var body: some View {
        ZStack {
            switch step {

            case 0:
                // Single right arrow — fold right edge over the center crease
                arrow("arrow.right")
                    .offset(x: -80)
                    .offset(x: pulse ? 10 : 2, y: 0)

            case 1:
                // Two outward arrows — spread paper open (unfold)
                arrow("arrow.left")
                    .offset(x: 38, y: 0)
                    .offset(x: pulse ? -8 : 0)
                
 
            case 2:
                // Two diagonal arrows at top corners pointing down-inward
                arrow("arrow.down.right")
                    .offset(x: -90, y: -110)
                    .offset(x: pulse ? 5 : 0, y: pulse ? 5 : 0)
                arrow("arrow.down.left")
                    .offset(x: 90, y: -110)
                    .offset(x: pulse ? -5 : 0, y: pulse ? 5 : 0)

            case 3:
                // Two inward arrows from slanted edges toward center spine
                arrow("arrow.down.right")
                    .offset(x: -85, y: 5)
                    .offset(x: pulse ? 5 : 0, y: pulse ? 5 : 0)
                arrow("arrow.down.left")
                    .offset(x: 85, y: 5)
                    .offset(x: pulse ? -5 : 0, y: pulse ? 5 : 0)

            case 4:
                // Single right arrow — fold entire body in half along spine
                arrow("arrow.right")
                    .offset(x: -50)
                    .offset(x: pulse ? 10 : 2, y: 0)

            case 5:
                // Two down arrows showing wing fold direction
                
                arrow("arrow.down.left")
                    .offset(x: 18, y: -55)
                    .offset(y: pulse ? 8 : 0)

            case 6:
                // Circular arrow — flip the plane over
                arrow("arrow.2.circlepath")
                    .scaleEffect(pulse ? 1.15 : 1.0)

            case 7:
                // Single down arrow for the remaining wing
                arrow("arrow.down.right")
                    .offset(x: -28, y: -50)
                    .offset(y: pulse ? 8 : 0)

            default:
                EmptyView()
            }
        }
        .animation(.easeInOut(duration: 0.85).repeatForever(autoreverses: true), value: pulse)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { pulse = true }
        }
    }

    private func arrow(_ name: String) -> some View {
        Image(systemName: name)
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(accentColor.opacity(0.70))
            .shadow(color: accentColor.opacity(0.30), radius: 5, y: 2)
    }
}

// MARK: - FoldingPaper
// True silhouettes matching each of the 9 folding steps.
//
// Step 0 — Full portrait rectangle (the flat letter)
// Step 1 — Half-width strip (folded lengthwise)
// Step 2 — Full rectangle again (unfolded, center crease visible via FoldCreaseLine)
// Step 3 — House / pentagon (top corners folded down to center crease)
// Step 4 — Tall skinny triangle (diagonal edges folded in to spine)
// Step 5 — Very narrow pointed strip (body folded in half along spine, top view)
// Step 6 — Asymmetric dart (first wing folded down, right side; top view)
// Step 7 — Mirror dart (plane flipped; left wing still up, to be folded)
// Step 8 — Swept dart silhouette (both wings down, final top view)

struct FoldingPaper: Shape {
    var step: Int

    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let mx = rect.midX

        switch step {

        case 0:
            // ── Full portrait rectangle (the letter) ──
            return Path(rect)

        case 1:
            // ── Half-width strip (folded lengthwise) ──
            let pw = w * 0.50
            let px = mx - pw / 2
            var p = Path()
            p.move(to:    .init(x: px,      y: 0))
            p.addLine(to: .init(x: px + pw, y: 0))
            p.addLine(to: .init(x: px + pw, y: h))
            p.addLine(to: .init(x: px,      y: h))
            p.closeSubpath()
            return p

        case 2:
            // ── Full rectangle again (unfolded) ──
            // FoldCreaseLine will draw the two diagonal guides over this shape
            return Path(rect)

        case 3:
            // ── House / pentagon (top corners folded to center crease) ──
            let pw = w
            let px = mx - pw / 2
            let sy = h * 0.44          // shoulder height where diagonals meet body
            var p = Path()
            p.move(to:    .init(x: mx,      y: 0))       // peak (pointed top)
            p.addLine(to: .init(x: px + pw, y: sy))      // right shoulder
            p.addLine(to: .init(x: px + pw, y: h))       // bottom right
            p.addLine(to: .init(x: px,      y: h))       // bottom left
            p.addLine(to: .init(x: px,      y: sy))      // left shoulder
            p.closeSubpath()
            return p

        case 4:
            // ── Full-width House with a short 20% straight base ──
            let sy = h * 0.80          // Shoulder height (80% down, leaving 20% at the bottom)
            
            var p = Path()
            p.move(to:    .init(x: mx, y: 0))      // 1. Nose Tip (Top Center)
            p.addLine(to: .init(x: w,  y: sy))     // 2. Right Shoulder (Full Width)
            p.addLine(to: .init(x: w,  y: h))      // 3. Bottom Right
            p.addLine(to: .init(x: 0,  y: h))      // 4. Bottom Left
            p.addLine(to: .init(x: 0,  y: sy))     // 5. Left Shoulder (Full Width)
            p.closeSubpath()                       // 6. Back to Nose Tip
            return p

        case 5:
            // ── Right-Half of Case 4 (The closed plane profile) ──
            let sy = h * 0.80          // Keep the same shoulder height as Case 4
            
            var p = Path()
            p.move(to:    .init(x: mx, y: 0))      // 1. Nose Tip (Top Center)
            p.addLine(to: .init(x: w,  y: sy))     // 2. Right Shoulder (Full Right Edge)
            p.addLine(to: .init(x: w,  y: h))      // 3. Bottom Right
            p.addLine(to: .init(x: mx, y: h))      // 4. Bottom Center (On the spine)
            p.closeSubpath()                       // 5. Back up to the Nose
            return p
             
        case 6:
            let sy = h * 0.80
            let foldX = w * 0.80
            var p = Path()
            
            // 1. Start at the Nose
            p.move(to: .init(x: mx, y: 0))
            
            // 2. To Right Shoulder
            p.addLine(to: .init(x: w, y: sy))
            
            // 3. To Bottom Right Corner
            p.addLine(to: .init(x: w, y: h))
            
            // 4. To the Bottom Fold Anchor (where wing meets body)
            p.addLine(to: .init(x: foldX, y: h))
            
            // 5. To the Wing Tip (The overhang point)
            p.addLine(to: .init(x: w * 0.75, y: h + 14))
            
            // 6. To the Spine Hinge (where wing fold starts)
            p.addLine(to: .init(x: w * 0.65, y: h))
            
            // 7. To the Bottom of the Spine (Tail)
            p.addLine(to: .init(x: mx, y: h))
            
            // 8. Close back to Nose
            p.closeSubpath()
            
            return p
            
        case 7:
            // ── Mirrored Silhouette of Step 6 (Left Side) ──
            let sy = h * 0.80
            let mirroredFoldX = w * 0.20 // Mirrored from 0.80w
            var p = Path()
             
            // 1. Start at the Nose
            p.move(to: .init(x: mx, y: 0))
            
            // 2. To Left Shoulder (Mirrored from w)
            p.addLine(to: .init(x: 0, y: sy))
            
            // 3. To Bottom Left Corner (Mirrored from w, h)
            p.addLine(to: .init(x: 0, y: h))
            
            // 4. To the Bottom Fold Anchor (Mirrored from foldX)
            p.addLine(to: .init(x: mirroredFoldX, y: h))
            
            // 5. To the Wing Tip (Mirrored from 0.75w, h + 14)
            p.addLine(to: .init(x: w * 0.25, y: h + 14))
            
            // 6. To the Spine Hinge (Mirrored from 0.65w, h)
            p.addLine(to: .init(x: w * 0.35, y: h))
            
            // 7. To the Bottom of the Spine (Tail)
            p.addLine(to: .init(x: mx, y: h))
            
            // 8. Close back to Nose
            p.closeSubpath()
            
            return p

        default:
            // ── Swept dart silhouette (both wings down, final top view) ──
            var p = Path()
            p.move(to:    .init(x: mx,       y: h * 0.04))  // nose tip
            p.addLine(to: .init(x: w - 6,    y: h * 0.72))  // right wingtip
            p.addLine(to: .init(x: mx + 16,  y: h * 0.86))  // right tail notch
            p.addLine(to: .init(x: mx,       y: h * 0.96))  // tail center
            p.addLine(to: .init(x: mx - 16,  y: h * 0.86))  // left tail notch
            p.addLine(to: .init(x: 6,        y: h * 0.72))  // left wingtip
            p.closeSubpath()
            return p
        }
    }
}

// MARK: - FoldCreaseLine
// Dashed guide showing WHERE to make the next fold.

struct FoldCreaseLine: Shape {
    var step: Int

    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        let mx = rect.midX
        var p = Path()

        switch step {

        case 0:
            // Vertical center line — "fold here lengthwise"
            p.move(to:    .init(x: mx, y: h * 0.06))
            p.addLine(to: .init(x: mx, y: h * 0.94))

        case 1:
            // Vertical center crease made in step 0 (now unfold along this line)
            EmptyView()

        case 2:
            // 1. The Peak: Middle of the paper at the very top
            let peak = CGPoint(x: mx, y: 0)
            
            // 2. Left Slant: From top-middle to the left edge at 44% height
            p.move(to: peak)
            p.addLine(to: .init(x: 0, y: h * 0.44))
            
            // 3. Right Slant: From top-middle to the right edge at 44% height
            p.move(to: peak)
            p.addLine(to: .init(x: w, y: h * 0.44))
            
        case 3:
            // The point that is 30% up from the bottom (70% down from the top)
            let endY = h * 0.80
            
            // Start at the very top of the middle crease (the nose)
            let nose = CGPoint(x: mx, y: 0)
            
            // 1. Line to the very left edge
            p.move(to: nose)
            p.addLine(to: .init(x: 0, y: endY))
            
            // 2. Line to the very right edge
            p.move(to: nose)
            p.addLine(to: .init(x: w, y: endY))
            
        case 4:
            // Vertical center spine — "fold entire body along this"
            p.move(to:    .init(x: mx, y: h * 0.03))
            p.addLine(to: .init(x: mx, y: h * 0.97))

        case 5:
            // ── Wing Fold Guide ──
            // From the nose tip (top of spine)
            // to 75% across the bottom edge
            p.move(to:    .init(x: mx,       y: 0))
            p.addLine(to: .init(x: w * 0.80, y: h))

  
        case 7:
            // Guide for the second wing fold (left side, mirrored)
            p.move(to:    .init(x: mx,       y: 0))
            p.addLine(to: .init(x: w * 0.22,  y: h))
 
        default:
            break
        }

        return p
    }
}

// MARK: - Envelope flap overlay

struct EnvelopeFlapOverlay: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to:    CGPoint(x: 0,                y: rect.height * 0.28))
        path.addLine(to: CGPoint(x: rect.width * 0.5, y: 0))
        path.addLine(to: CGPoint(x: rect.width,       y: rect.height * 0.28))
        path.closeSubpath()
        return path
    }
}

// MARK: - Step dots (9 total)

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



#Preview {
    RitualView(envelopeColorIndex: 0, onComplete: {},
               onCancel:   {})
    
}


