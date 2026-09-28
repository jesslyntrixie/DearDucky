// DearDucky/Views/Ritual/Components/CompletedCreaseLines.swift


import SwiftUI


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
                    EmptyView()

                case 1:
                    EmptyView()

                case 2:
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
                        line(from: .init(x:mx, y: h * 0.91), to:  .init(x: w * 0.65, y: h))
                        
                    
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

    // MARK: - Helper Drawing Functions
    
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
