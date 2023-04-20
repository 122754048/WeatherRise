import SwiftUI
import CoreData
import CoreLocation

@main
struct WeatherRiseApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, appState.managedObjectContext)
                .environmentObject(appState)
        }
    }
}
