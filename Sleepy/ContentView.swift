import SwiftUI
import HKVisualKit

struct ContentView: View {
    var body: some View {
        Text("Example of shared component usage")
        ErrorView(errorType: .brokenData(type: .energy))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
