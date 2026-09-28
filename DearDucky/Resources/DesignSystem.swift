// DearDucky/Resources/DesignSystem

import SwiftUI

// MARK: - Color Palette
// Sky blue is the hero color. All other colors are intentionally muted
// so they support the scene without competing.
extension Color {
    static let skyBright   = Color(red: 0.33, green: 0.83, blue: 0.99)  
    static let skyLight    = Color(red: 0.75, green: 0.91, blue: 1.00)
    static let skyDeep     = Color(red: 0.15, green: 0.48, blue: 0.88)
    static let gardenGreen = Color(red: 0.26, green: 0.70, blue: 0.50)  // slightly muted (was 0.80)
    static let leafGreen   = Color(red: 0.14, green: 0.56, blue: 0.36)  // muted (was 0.62)
    static let mintFresh   = Color(red: 0.42, green: 0.80, blue: 0.62)  // softer (was 0.95)
    static let sunYellow   = Color(red: 1.00, green: 0.84, blue: 0.18)  // duck color — unchanged
    static let peach       = Color(red: 1.00, green: 0.66, blue: 0.50)  // slightly muted (was 0.62)
    static let coral       = Color(red: 0.96, green: 0.44, blue: 0.42)  // slightly muted (was 1.00/0.42)
    static let blush       = Color(red: 1.00, green: 0.78, blue: 0.84)  // softer (was 0.75/0.82)
    static let lavender    = Color(red: 0.72, green: 0.60, blue: 0.94)  // muted (was 0.98)
    static let lilac       = Color(red: 0.88, green: 0.80, blue: 0.98)  // unchanged
    static let paperCream  = Color(red: 0.99, green: 0.97, blue: 0.91)  // unchanged
    static let tableWarm   = Color(red: 0.94, green: 0.89, blue: 0.78)  // unchanged
    static let inkColor    = Color(red: 0.14, green: 0.18, blue: 0.26)  // unchanged
    static let inkLight    = Color(red: 0.38, green: 0.43, blue: 0.54)  // unchanged
    
    
    static let skyBrightShadow  = Color(red: 0.17, green: 0.42, blue: 0.66)
    static let gardenGreenShadow = Color(red: 0.16, green: 0.45, blue: 0.32)  
    static let sunYellowShadow  = Color(red: 0.70, green: 0.56, blue: 0.08)
    static let peachShadow      = Color(red: 0.68, green: 0.42, blue: 0.28)
    static let lavenderShadow   = Color(red: 0.46, green: 0.36, blue: 0.64)
    static let paperCreamShadow = Color(red: 0.76, green: 0.72, blue: 0.62)
    static let coralShadow = Color(red: 0.62, green: 0.26, blue: 0.24)
    
}

// MARK: - Envelope Palette (6 hopeful colors)
struct EnvelopePalette {
    struct Entry {
        let main: Color
        let light: Color
        let shadow: Color
        let name: String
    }
    
    static let all: [Entry] = [
        Entry(main: .skyBright,   light: .skyLight,
                      shadow: .skyBrightShadow,                                         name: "Sky"),
                Entry(main: .gardenGreen, light: .mintFresh,
                      shadow: .gardenGreenShadow,                                       name: "Sage"),
                Entry(main: .peach,       light: Color(red:1.00, green:0.88, blue:0.82),
                      shadow: .peachShadow,                                             name: "Peach"),
                Entry(main: .lavender,    light: .lilac,
                      shadow: .lavenderShadow,                                          name: "Lilac"),
                Entry(main: .sunYellow,   light: Color(red:1.00, green:0.96, blue:0.72),
                      shadow: .sunYellowShadow,                                         name: "Sunny"),
                Entry(main: .coral,       light: Color(red:1.00, green:0.78, blue:0.76),
                      shadow: .coralShadow, name: "Coral")
    ]
    
    static func main(_ i: Int)   -> Color  { all[i % all.count].main }
        static func light(_ i: Int)  -> Color  { all[i % all.count].light }
        static func shadow(_ i: Int) -> Color  { all[i % all.count].shadow }
        static func name(_ i: Int)   -> String { all[i % all.count].name }
}

// MARK: - Finch-style Button
struct FinchButtonStyle: ButtonStyle {
    var color: Color = .skyBright
    var textColor: Color = .white

    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .fill(color.opacity(0.45))
                .offset(y: configuration.isPressed ? 2 : 6)
            RoundedRectangle(cornerRadius: 30)
                .fill(color)
                .offset(y: configuration.isPressed ? 3 : 0)
                .overlay(
                    configuration.label
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(textColor)
                        .offset(y: configuration.isPressed ? 3 : 0)
                )
        }
        .frame(height: 60)
        .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.5), value: configuration.isPressed)
    }
}

// MARK: - Cloud
struct CloudView: View {
    var scale: CGFloat = 1.0
    var opacity: Double = 0.90

    var body: some View {
        ZStack {
            Capsule()
                .fill(Color.white.opacity(opacity))
                .frame(width: 88 * scale, height: 30 * scale)
                .offset(y: 9 * scale)
            Circle()
                .fill(Color.white.opacity(opacity))
                .frame(width: 36 * scale, height: 36 * scale)
                .offset(x: -20 * scale, y: 2 * scale)
            Circle()
                .fill(Color.white.opacity(opacity))
                .frame(width: 48 * scale, height: 48 * scale)
                .offset(x: 4 * scale, y: -5 * scale)
            Circle()
                .fill(Color.white.opacity(opacity))
                .frame(width: 32 * scale, height: 32 * scale)
                .offset(x: 28 * scale, y: 4 * scale)
        }
    }
}

// MARK: - Sky Background
struct SkyBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.skyDeep, Color.skyBright, Color.skyLight],
                startPoint: .top, endPoint: .bottom
            )
            CloudView(scale: 1.1, opacity: 0.85).position(x: 80,  y: 130)
            CloudView(scale: 0.65, opacity: 0.72).position(x: 310, y: 195)
            CloudView(scale: 0.90, opacity: 0.78).position(x: 200, y: 80)
            CloudView(scale: 0.50, opacity: 0.60).position(x: 55,  y: 300)
        }
        .ignoresSafeArea()
    }
}

// MARK: - Table Background
struct TableBackground: View {
    var body: some View {
        ZStack {
            Color.tableWarm
            ForEach(0..<14, id: \.self) { i in
                Path { path in
                    let y = CGFloat(i) * 52 + 18
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addCurve(
                        to: CGPoint(x: 440, y: y + CGFloat(i % 3) * 5),
                        control1: CGPoint(x: 110, y: y - 3),
                        control2: CGPoint(x: 300, y: y + 4)
                    )
                }
                .stroke(Color.brown.opacity(0.055), lineWidth: 1.0)
            }
        }
        .ignoresSafeArea()
    }
}
// MARK: - Wax Seal
struct WaxSeal: View {
    var mainColor: Color
    var lightColor: Color
    var size: CGFloat = 32

    var body: some View {
        ZStack {
            Image(systemName: "heart.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(Color.coral)
                .frame(width: 20, height: 20)
                .offset(x: 0, y: 15)
                
                
        }
        
    }
}

// MARK: - Envelope Color Picker
struct EnvelopeColorPicker: View {
    @Binding var selectedIndex: Int

    var body: some View {
        HStack(spacing: 10) {
            HStack(spacing: 9) {
                ForEach(0..<EnvelopePalette.all.count, id: \.self) { i in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            selectedIndex = i
                        }
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(EnvelopePalette.main(i))
                                .frame(width: 26, height: 26)
                            if selectedIndex == i {
                                Circle()
                                    .strokeBorder(Color.white, lineWidth: 2.5)
                                    .frame(width: 26, height: 26)
                                Circle()
                                    .strokeBorder(EnvelopePalette.main(i), lineWidth: 1.5)
                                    .frame(width: 32, height: 32)
                            }
                        }
                    }
                    .scaleEffect(selectedIndex == i ? 1.15 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedIndex)
                }
            }
        }
        .padding(.vertical, 12)
    }
}
