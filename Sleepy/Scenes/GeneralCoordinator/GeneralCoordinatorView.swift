import SwiftUI
import XUI

struct GeneralCoordinatorView: View {

    // MARK: Stored Properties

    @Store var coordinator: GeneralCoordinator

    // MARK: Views

    var body: some View {
        TabView(selection: $coordinator.tab) {

            FeedNavigationCoordinatorView(coordinator: coordinator.mainCoordinator)
            .tabItem { Label("main", systemImage: "hare.fill") }
            .tag(HomeTab.main)

            //HistoryCoordinatorView(coordinator: coordinator.historyCoordinator)
//                .tabItem { Label("main", systemImage: "hare.fill") }
//                .tag(HomeTab.history)
        }
    }

}
