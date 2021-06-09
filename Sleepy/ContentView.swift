import SwiftUI
import HKVisualKit

struct ContentView: View {

    // MARK: Private properties

    private let colorSchemeProvider: ColorSchemeProvider

    // MARK: Init

    init(colorSchemeProvider: ColorSchemeProvider) {
        self.colorSchemeProvider = colorSchemeProvider
    }

    // MARK: View body

    var body: some View {
        Text("Example of shared component usage")
        ErrorView(errorType: .brokenData(type: .energy),
                  colorScheme: colorSchemeProvider.sleepyColorScheme)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(colorSchemeProvider: ColorSchemeProvider())
    }
}
