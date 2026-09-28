import Foundation
import SwiftData

@Model
class Letter {
    var title: String
    var content: String
    var timestamp: Date
    var envelopeColorIndex: Int  // index into a fixed palette

    init(title: String, content: String, timestamp: Date = .now, envelopeColorIndex: Int = 0) {
        self.title = title
        self.content = content
        self.timestamp = timestamp
        self.envelopeColorIndex = envelopeColorIndex
    }
}
