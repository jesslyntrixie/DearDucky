import Foundation
import SwiftUI

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
 


