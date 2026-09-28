import SwiftUI
import SwiftData


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

                    // Sun
                    Circle()
                        .fill(Color.sunYellow.opacity(0.35))
                        .frame(width: w * 0.20, height: w * 0.20)
                        .position(x: w * 0.83, y: h * 0.18)
                    Circle()
                        .fill(Color.sunYellow)
                        .frame(width: w * 0.13, height: w * 0.13)
                        .position(x: w * 0.83, y: h * 0.18)

                   
                    // ── Back hill (mint) ──
                    Ellipse()
                        .fill(Color.gardenGreen)
                        .frame(width: w * 1.55, height: h * 0.58)
                        .position(x: w * 0.30, y: h * 0.90)

                    // ── Front hill (garden green) ──
                    Ellipse()
                        .fill(Color.mintFresh)
                        .frame(width: w * 1.45, height: h * 0.52)
                        .position(x: w * 0.60, y: h * 0.97)
                    
                    // ── Pond — RIGHT of duck (duck is centred ~0.50) ──
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

                    // ── Flowers with stems + leaves ──

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
                        // Leaf
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

                
                VStack(spacing: 0) {
                    Spacer()

                    ZStack(alignment: .bottomLeading) {
                        // Speech bubble
                        VStack(spacing: 0) {
                            Text("What would you tell\nyour future self?")
                                .font(.system(.subheadline, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(.inkColor)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color.white.opacity(0.88))
//                                        .shadow(color: .black.opacity(0.08), radius: 6, y: 3)

                                )

                            // Bubble tail pointing down-left toward duck
                            Image(systemName: "arrowtriangle.down.fill")
                                .font(.system(size: 10))
                                .foregroundColor(Color.white.opacity(0.88))
                                .offset(x: -18, y: -3)
                        }
                        .offset(x: 20, y: -8)
                    }

                    MascotDuckView()
                        .frame(width: 100, height: 110)
                        .scaleEffect(0.7)

                    Spacer().frame(height: 4)
                }



                Spacer().frame(height: 4)
            }
        }
    }
}
