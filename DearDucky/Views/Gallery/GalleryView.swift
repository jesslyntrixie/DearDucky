// DearDucky/Views/Gallery/GalleryView

import SwiftUI
import SwiftData

// ─────────────────────────────────────────────
// MARK: - Gallery View
// ─────────────────────────────────────────────
struct GalleryView: View {
    @Query(sort: \Letter.timestamp, order: .reverse) private var letters: [Letter]
    @State private var selectedLetter: Letter? = nil
    @State private var searchText = ""

    private var filtered: [Letter] {
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            return letters
        }
        let q = searchText.lowercased()
        return letters.filter {
            $0.title.lowercased().contains(q) ||
            $0.content.lowercased().contains(q)
        }
    }

    var body: some View {
        ZStack {
            Color.tableWarm.ignoresSafeArea()

            if letters.isEmpty {
                EmptyGalleryView()
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 16) {
                        // ── Result count when searching ──
                        if !searchText.isEmpty {
                            HStack {
                                Text(filtered.isEmpty
                                     ? "No letters found"
                                     : "\(filtered.count) letter\(filtered.count == 1 ? "" : "s") found")
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundColor(.inkColor.opacity(0.45))
                                Spacer()
                            }
                            .padding(.horizontal, 4)
                            .padding(.top, 4)
                        }

                        if filtered.isEmpty && !searchText.isEmpty {
                            // Empty search state
                            VStack(spacing: 12) {
                                Text("✉️")
                                    .font(.system(size: 40))
                                Text("No letters match\n\"\(searchText)\"")
                                    .font(.system(.subheadline, design: .rounded))
                                    .foregroundColor(.inkColor.opacity(0.45))
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.top, 60)
                        } else {
                            ForEach(filtered) { letter in
                                EnvelopeCard(letter: letter)
                                    .onTapGesture {
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        selectedLetter = letter
                                    }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 44)
                }
                // ── Search bar — built into nav, standard iOS pattern ──
                .searchable(
                    text: $searchText,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Search letters…"
                )
            }
        }
        // ── Title ──
        // "My Letters" left-aligned large title is iOS standard (same as Notes/Mail)
        // The tableWarm background unifies the nav bar with the content below it
        .navigationTitle("My Letters")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(Color.tableWarm, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
        .sheet(item: $selectedLetter) { letter in
            LetterSheetView(letter: letter)
        }
    }
}

// ─────────────────────────────────────────────
// MARK: - Letter Sheet
// ─────────────────────────────────────────────
struct LetterSheetView: View {
    let letter: Letter
    @State private var appeared = false

    private var main:  Color { EnvelopePalette.main(letter.envelopeColorIndex) }
    private var light: Color { EnvelopePalette.light(letter.envelopeColorIndex) }

    var body: some View {
        ZStack(alignment: .top) {
            Color.tableWarm.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Capsule()
                        .fill(Color.inkColor.opacity(0.18))
                        .frame(width: 36, height: 4)
                        .padding(.top, 12)
                        .padding(.bottom, 8)

                    LetterPaperView(letter: letter, accentColor: main)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 16)
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.50, dampingFraction: 0.80).delay(0.08)) {
                appeared = true
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
        .presentationCornerRadius(24)
        .presentationBackground(Color.tableWarm)
    }
}

// ─────────────────────────────────────────────
// MARK: - Envelope Card
// ─────────────────────────────────────────────
struct EnvelopeCard: View {
    let letter: Letter

    private var main:  Color { EnvelopePalette.main(letter.envelopeColorIndex) }
    private var light: Color { EnvelopePalette.light(letter.envelopeColorIndex) }

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geo in
                ZStack {
                    light.opacity(0.60)
                    Path { path in
                                path.move(to: .zero)
                        path.addLine(to: CGPoint(x: geo.size.width, y: 0))
                                // We curve back to the start.
                                // The control point is at the bottom center to create the "U" shape.
                                // Using height * 2 makes the curve look more like a flap and less like a circle.
                                path.addQuadCurve(to: .zero,
                                                  control: CGPoint(x: geo.size.width / 2, y: geo.size.height * 2.1))
                            }
                            .fill(main.opacity(0.22))
//
                }
            }
            .frame(height: 44)
            .zIndex(1)

            ZStack(alignment: .center) {
                Rectangle().fill(light.opacity(0.60))
//                Rectangle().strokeBorder(main.opacity(0.28), lineWidth: 1.2)

                HStack(alignment: .center, spacing: 14) {
//                    FoldingPaper(step: 8)
//                        .fill(main.opacity(0.55))
//                        .frame(width: 32, height: 24)

                    HStack(alignment: .firstTextBaseline) { // Aligns the "bottom" of the fonts
                        Text(letter.title)
                            .font(.system(.subheadline, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.inkColor)
                            .lineLimit(1)           // Forces the title to stay on one line
                            .truncationMode(.tail)  // Adds the "..." at the end
                        
                        Spacer(minLength: 16)       // Ensures there is ALWAYS at least a 16pt gap
                        
                        Text(letter.timestamp.formatted(.dateTime.day().month(.abbreviated).year()))
                            .font(.system(.caption2, design: .rounded))
                            .foregroundColor(.inkColor.opacity(0.45))
                            .fixedSize()
                    }

                    
                    
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
            }
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: 16,
                    bottomTrailingRadius: 16,
                    topTrailingRadius: 0
                )
            )
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
//        .shadow(color: main.opacity(0.18), radius: 10, y: 4)
//        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
        .overlay(){
            WaxSeal(
                mainColor: EnvelopePalette.main(letter.envelopeColorIndex),
                lightColor: EnvelopePalette.light(letter.envelopeColorIndex),
                
                size: 30
            )
                .offset(x: 0, y: -13)
        }
    }
}

// ─────────────────────────────────────────────
// MARK: - Letter Paper
// ─────────────────────────────────────────────
struct LetterPaperView: View {
    let letter: Letter
    let accentColor: Color

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.78, green: 0.72, blue: 0.58).opacity(0.38))
                .offset(x: 2, y: 6)

            RoundedRectangle(cornerRadius: 16)
                .fill(Color.paperCream)

            VStack(spacing: 0) {
                Spacer().frame(height: 78)
                ForEach(0..<16, id: \.self) { _ in
                    Spacer()
                    Rectangle()
                        .fill(accentColor.opacity(0.10))
                        .frame(height: 1)
                }
                Spacer()
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))

            Rectangle()
                .fill(Color.peach.opacity(0.38))
                .frame(width: 1.5)
                .padding(.leading, 48)
                .clipShape(RoundedRectangle(cornerRadius: 16))

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top) {
                    Spacer()
                    Text(letter.timestamp, style: .date)
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.inkColor.opacity(0.32))
                        .padding(.top, 14)
                    StampDecoration()
                        .padding(.trailing, 8)
                }
                .padding(.trailing, 14)

                Text(letter.title)
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.inkColor)
                    .padding(.leading, 60)
                    .padding(.trailing, 16)

                Rectangle()
                    .fill(Color.inkColor.opacity(0.07))
                    .frame(height: 1)
                    .padding(.leading, 60)
                    .padding(.trailing, 16)
                    .padding(.bottom, 4)

                Text(letter.content)
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.inkColor.opacity(0.82))
                    .lineSpacing(4)
                    .padding(.leading, 58)
                    .padding(.trailing, 16)
                    .padding(.bottom, 24)
            }
        }
//        .shadow(color: .black.opacity(0.06), radius: 12, y: 5)
    }
}

// ─────────────────────────────────────────────
// MARK: - Empty State
// ─────────────────────────────────────────────
struct EmptyGalleryView: View {
    @State private var floatOffset: CGFloat = 0

    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(Color.inkColor.opacity(0.06))
                    .frame(width: 110, height: 110)
                FoldingPaper(step: 8)
                    .fill(Color.inkColor.opacity(0.22))
                    .frame(width: 64, height: 48)
                    .rotationEffect(.degrees(-35))
                    .offset(y: floatOffset)
            }
            Text("No letters yet")
                .font(.system(.title2, design: .rounded))
                .fontWeight(.heavy)
                .foregroundColor(.inkColor.opacity(0.72))
            Text("Write your first letter,\nfold it, and fly it here.")
                .font(.system(.body, design: .rounded))
                .foregroundColor(.inkColor.opacity(0.42))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                floatOffset = -10
            }
        }
    }
}

// ─────────────────────────────────────────────
// MARK: - Preview
// ─────────────────────────────────────────────
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Letter.self, configurations: config)

    let samples: [Letter] = [
        Letter(
            title: "I almost quit today",
            content: "I don't know if I'm good enough for this. Everyone else seems to have it figured out and I'm just pretending. I'm writing this so that if I ever make it through, future me will remember how close I came to walking away. Please don't forget how hard this was.",
            timestamp: Calendar.current.date(byAdding: .month, value: -10, to: .now)!,
            envelopeColorIndex: 3
        ),
        Letter(
            title: "First week at the new job",
            content: "I have no idea what I'm doing and everyone seems so much smarter. I smile and nod and then go home and google everything. I hope future me laughs at this. I hope it gets easier.",
            timestamp: Calendar.current.date(byAdding: .month, value: -9, to: .now)!,
            envelopeColorIndex: 0
        ),
        Letter(
            title: "The day everything changed",
            content: "Something shifted today. I can't explain it yet but I feel like I turned a corner. I want you to remember this exact feeling — not the achievement, just the quiet moment before it when I chose to keep going.",
            timestamp: Calendar.current.date(byAdding: .month, value: -7, to: .now)!,
            envelopeColorIndex: 2
        ),
        Letter(
            title: "I got the call",
            content: "It happened. After everything. I sat in my car for ten minutes before I could even call mum. I just want to remember this specific feeling of relief mixed with disbelief. Future me — you earned this.",
            timestamp: Calendar.current.date(byAdding: .month, value: -5, to: .now)!,
            envelopeColorIndex: 4
        ),
        Letter(
            title: "Missing home",
            content: "Some days the distance feels enormous. I cooked the same rice dish mum used to make and cried a little. I'm okay. I just want future me to know it was hard to be far away, and I did it anyway.",
            timestamp: Calendar.current.date(byAdding: .month, value: -4, to: .now)!,
            envelopeColorIndex: 5
        ),
        Letter(
            title: "To the me who made it",
            content: "If you're reading this, you got through the hard part. I'm proud of you in advance. I know it cost you something to get here. I know there were nights you cried and mornings you didn't want to get up. It was worth it.",
            timestamp: Calendar.current.date(byAdding: .month, value: -2, to: .now)!,
            envelopeColorIndex: 1
        ),
        Letter(
            title: "A perfectly ordinary Tuesday",
            content: "Nothing big happened today. I had good coffee, the light through the window was nice, and I felt okay. I'm writing this because I think future me might forget that ordinary days like this existed. Not every moment has to be a turning point.",
            timestamp: Calendar.current.date(byAdding: .day, value: -18, to: .now)!,
            envelopeColorIndex: 4
        ),
        Letter(
            title: "I said no for the first time",
            content: "I turned something down today. Something I would have said yes to out of fear six months ago. It felt terrifying and then it felt like freedom. I think this is what growing up actually feels like.",
            timestamp: Calendar.current.date(byAdding: .day, value: -10, to: .now)!,
            envelopeColorIndex: 0
        ),
        Letter(
            title: "I forgave myself today",
            content: "I spent a long time being angry at myself for that. Today I let it go. I don't know if future me has more things to forgive yet, but I hope you're gentler with yourself than I was. You're doing the best you can.",
            timestamp: Calendar.current.date(byAdding: .day, value: -3, to: .now)!,
            envelopeColorIndex: 5
        ),
    ]

    samples.forEach { container.mainContext.insert($0) }

    return NavigationStack { GalleryView() }
        .modelContainer(container)
}
