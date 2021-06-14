import SwiftUI
import XUI

struct RootCoordinatorView: View {

    // MARK: Stored Properties

    @Store var coordinator: RootCoordinator

    // MARK: Views

    var body: some View {
        TabView(selection: $coordinator.tab) {
            FeedNavigationCoordinatorView(coordinator: coordinator.feedCoordinator)
                .tabItem { Label("main", systemImage: "hare.fill") }
                .tag(TabBarTab.feed)
            
            //HistoryCoordinatorView(coordinator: coordinator.historyCoordinator)
            //                .tabItem { Label("main", systemImage: "hare.fill") }
            //                .tag(HomeTab.history)
        }
    }

}
