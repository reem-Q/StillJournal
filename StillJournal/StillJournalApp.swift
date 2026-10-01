import SwiftUI
import SwiftData

@main
struct StillJournalApp: App {
    var body: some Scene {
        WindowGroup {
            JournalListView()
        }
        .modelContainer(for: JournalEntry.self)
    }
}
