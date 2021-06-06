import SwiftUI
import XUI

struct GeneralCoordinatorView: View {

    // MARK: Stored Properties

    @Store var coordinator: GeneralCoordinator

    // MARK: Views

    var body: some View {
        TabView(selection: $coordinator.tab) {

            MainListCoordinatorView(coordinator: coordinator.mainCoordinator)
            .tabItem { Label("main", systemImage: "hare.fill") }
            .tag(HomeTab.main)
            
        }
    }

}
