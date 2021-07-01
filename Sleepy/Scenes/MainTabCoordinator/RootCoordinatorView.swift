import SwiftUI
import XUI

struct RootCoordinatorView: View {
    
    // MARK: Stored Properties
    
    @Store var coordinator: RootCoordinator

    // MARK: Views
    
    var body: some View {
        TabView(selection: $coordinator.tab) {
            FeedNavigationCoordinatorView(coordinator: coordinator.feedCoordinator)
                .tabItem { Label("summary", systemImage: "hare.fill") }
                .tag(TabBarTab.summary)
            
            HistoryCoordinatorView(coordinator: coordinator.historyCoordinator)
                .tabItem { Label("history", systemImage: "hare.fill") }
                .tag(TabBarTab.history)
            
            AlarmCoordinatorView(coordinator: coordinator.alarmCoordinator)
                .tabItem { Label("alarm", systemImage: "hare.fill") }
                .tag(TabBarTab.alarm)
            
            SettingsCoordinatorView(coordinator: coordinator.settingsCoordinator)
                .tabItem { Label("settings", systemImage: "hare.fill") }
                .tag(TabBarTab.settings)
        }
    }
    
}
