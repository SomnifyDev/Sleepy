import SwiftUI

@main
struct SleepyApp: App {
    @State var shouldShowNavigationView = false

    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                if shouldShowNavigationView {
                    MainNavigationView()
                } else {
                    NeedHealthAccessView()
                }
            }
            .onAppear {
                HealthManager.shared.checkReadPermissions(type: .activeBurnedEnergy) { access, error in
                    guard access else { return }
                    HealthManager.shared.checkReadPermissions(type: .heart) { access, error in
                        guard access else { return }
                        shouldShowNavigationView = true
                    }
                }
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
