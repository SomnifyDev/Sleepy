import SwiftUI
import HKVisualKit

@main
struct SleepyApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    private let colorSchemeProvider: ColorSchemeProvider

    // MARK: Init
    
    init() {
        self.colorSchemeProvider = ColorSchemeProvider()
    }

    // MARK: View body
    
    var body: some Scene {
        WindowGroup {
            ContentView(colorSchemeProvider: colorSchemeProvider)
        }
    }
    
}
