import Foundation
import SwiftUI
// ─────────────────────────────────────────────
// MARK: - Clean Letter Card
// ─────────────────────────────────────────────
struct LetterCard: View {
    @Binding var title: String
    @Binding var content: String
    
    @FocusState.Binding var focusedField: CardField?
    enum CardField { case title, content }

    var body: some View {
        ZStack(alignment: .topLeading) {

            // SHADOW
//            RoundedRectangle(cornerRadius: 12)
//                .fill(Color(red: 0.72, green: 0.66, blue: 0.50))
//                .offset(x: 3, y: 7)
//                .allowsHitTesting(false)

            RoundedRectangle(cornerRadius: 12)
                .fill(Color.paperCream)
                .allowsHitTesting(false)

            Rectangle()
                .fill(Color.peach.opacity(0.50))
                .frame(width: 1.5)
                .padding(.leading, 54)
                .clipShape(RoundedRectangle(cornerRadius: 22))
                .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: 0) {

                HStack(alignment: .top) {
                    Spacer()
                    Text(Date(), style: .date)
                        .font(.system(.caption2, design: .rounded))
                        .foregroundColor(.inkColor.opacity(0.28))
                        .padding(.top, 18)
                    StampDecoration().padding(.trailing, 6)
                }
                .padding(.trailing, 16)

                Text("Dear Future Me,")
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundColor(.inkColor.opacity(0.80))
                    .padding(.leading, 66)
                    .padding(.trailing, 20)
                    .padding(.top, 6)
                    .padding(.bottom, 4)

                TextField("Give your letter a title…", text: $title)
                    .font(.system(.title3, design: .rounded).weight(.bold))
                    .foregroundColor(.inkColor)
                    .focused($focusedField, equals: .title)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .content }
                    .padding(.leading, 66)
                    .padding(.trailing, 20)

                Rectangle()
                    .fill(Color.inkColor.opacity(0.07))
                    .frame(height: 1)
                    .padding(.leading, 66)
                    .padding(.trailing, 20)
                    .padding(.vertical, 8)

                ZStack(alignment: .topLeading) {
                    if content.isEmpty {
                        Text("Write anything — hopes, gratitude,\ngoals, fears. Your future self will read this.")
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(.inkColor.opacity(0.22))
                            .padding(.leading, 66)
                            .padding(.trailing, 20)
                            .padding(.top, 8)
                            .allowsHitTesting(false)
                    }
                    TextEditor(text: $content)
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.inkColor)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .focused($focusedField, equals: .content)
                        .padding(.leading, 62)
                        .padding(.trailing, 16)
                        .padding(.bottom, 16)
                        .frame(minHeight: 180)
                }
            }
        }
//        .shadow(color: .black.opacity(0.10), radius: 14, y: 6)
        .onTapGesture {
            if focusedField == nil { focusedField = title.isEmpty ? .title : .content }
        }
    }
}
