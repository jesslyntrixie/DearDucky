import SwiftUI
import SwiftData

@main
struct FeixiangApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Letter.self])
        // Using migration policy to handle the new `title` and `envelopeColorIndex` fields
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
