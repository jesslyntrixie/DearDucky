// DearDucky/Views/Ritual/Components/FoldingPaper.swift

import SwiftUI


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
