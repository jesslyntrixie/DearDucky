// DearDucky/Views/Ritual/Components/FoldCreaseLine.swift

import SwiftUI


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
            p.move(to:    .init(x: mx, y: h * 0.06))
            p.addLine(to: .init(x: mx, y: h * 0.94))

        case 2:

            let peak = CGPoint(x: mx, y: 0)
            
            p.move(to: peak)
            p.addLine(to: .init(x: 0, y: h * 0.44))
            
            p.move(to: peak)
            p.addLine(to: .init(x: w, y: h * 0.44))
            
        case 3:
            let endY = h * 0.80
            
            let nose = CGPoint(x: mx, y: 0)
            
            p.move(to: nose)
            p.addLine(to: .init(x: 0, y: endY))

            p.move(to: nose)
            p.addLine(to: .init(x: w, y: endY))
            
        case 4:
            p.move(to:    .init(x: mx, y: h * 0.03))
            p.addLine(to: .init(x: mx, y: h * 0.97))

        case 5:
            p.move(to:    .init(x: mx,       y: 0))
            p.addLine(to: .init(x: w * 0.80, y: h))

  
        case 7:
            p.move(to:    .init(x: mx,       y: 0))
            p.addLine(to: .init(x: w * 0.22,  y: h))
 
        default:
            break
        }

        return p
    }
}
