import SwiftUI
import SwiftData

@main
struct SantaListApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Person.self,
            Gift.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        let context = sharedModelContainer.mainContext
        SeedData.seedInitialDataIfNeeded(context: context)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    await ReminderService.shared.requestAuthorization()
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
