import SwiftUI

// MARK: - 5-step folding: envelope → paper plane
// Step 0 — Sealed envelope (rectangle + flap triangle on top)
// Step 1 — Fold in half lengthwise (slim rectangle)
// Step 2 — Fold top corners to center (pentagon / pointed nose)
// Step 3 — Reverse-fold nose (sharper dart nose emerges)
// Step 4 — Fold wings down (classic dart plane silhouette)

struct FoldingPaper: Shape {
    var step: Int

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        switch step {

        case 0:
            // Sealed envelope body
            path.move(to: CGPoint(x: 0, y: h * 0.28))
            path.addLine(to: CGPoint(x: w, y: h * 0.28))
            path.addLine(to: CGPoint(x: w, y: h))
            path.addLine(to: CGPoint(x: 0, y: h))
            path.closeSubpath()
            // Flap triangle
            path.move(to: CGPoint(x: 0, y: h * 0.28))
            path.addLine(to: CGPoint(x: w * 0.5, y: 0))
            path.addLine(to: CGPoint(x: w, y: h * 0.28))
            path.closeSubpath()

        case 1:
            // Fold in half lengthwise — slim tall rectangle
            let insetX = w * 0.20
            path.addRoundedRect(
                in: CGRect(x: insetX, y: h * 0.05, width: w - insetX * 2, height: h * 0.90),
                cornerSize: CGSize(width: 6, height: 6)
            )

        case 2:
            // Fold top corners to center — pentagon with nose point
            let midX = w * 0.5
            path.move(to: CGPoint(x: 0, y: h))
            path.addLine(to: CGPoint(x: w, y: h))
            path.addLine(to: CGPoint(x: w, y: h * 0.42))
            path.addLine(to: CGPoint(x: midX, y: 0))
            path.addLine(to: CGPoint(x: 0, y: h * 0.42))
            path.closeSubpath()

        case 3:
            // Reverse-fold nose tip back — sharper dart nose
            let midX = w * 0.5
            path.move(to: CGPoint(x: 0, y: h))
            path.addLine(to: CGPoint(x: w, y: h))
            path.addLine(to: CGPoint(x: w, y: h * 0.30))
            path.addLine(to: CGPoint(x: midX + w * 0.15, y: h * 0.14))
            path.addLine(to: CGPoint(x: midX, y: h * 0.30))
            path.addLine(to: CGPoint(x: midX - w * 0.15, y: h * 0.14))
            path.addLine(to: CGPoint(x: 0, y: h * 0.30))
            path.closeSubpath()

        case 4:
            // Fold wings down — classic dart silhouette
            let midX = w * 0.5
            path.move(to: CGPoint(x: midX, y: 0))
            path.addLine(to: CGPoint(x: w, y: h * 0.68))
            path.addLine(to: CGPoint(x: midX + w * 0.10, y: h))
            path.addLine(to: CGPoint(x: midX - w * 0.10, y: h))
            path.addLine(to: CGPoint(x: 0, y: h * 0.68))
            path.closeSubpath()

        default:
            break
        }

        return path
    }
}

// MARK: - Crease lines per step

struct FoldCreaseLine: Shape {
    var step: Int

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        switch step {
        case 0:
            // Interior V fold lines of envelope
            path.move(to: CGPoint(x: 0, y: h * 0.28))
            path.addLine(to: CGPoint(x: w * 0.5, y: h * 0.60))
            path.addLine(to: CGPoint(x: w, y: h * 0.28))
        case 1:
            let cx = w * 0.50
            path.move(to: CGPoint(x: cx, y: h * 0.08))
            path.addLine(to: CGPoint(x: cx, y: h * 0.92))
        case 2:
            let midX = w * 0.5
            path.move(to: CGPoint(x: 0, y: h * 0.42))
            path.addLine(to: CGPoint(x: midX, y: 0))
            path.move(to: CGPoint(x: w, y: h * 0.42))
            path.addLine(to: CGPoint(x: midX, y: 0))
        case 3:
            path.move(to: CGPoint(x: w * 0.08, y: h * 0.30))
            path.addLine(to: CGPoint(x: w * 0.92, y: h * 0.30))
        case 4:
            let midX = w * 0.5
            path.move(to: CGPoint(x: midX, y: h * 0.04))
            path.addLine(to: CGPoint(x: midX, y: h * 0.90))
        default:
            break
        }

        return path
    }
}
