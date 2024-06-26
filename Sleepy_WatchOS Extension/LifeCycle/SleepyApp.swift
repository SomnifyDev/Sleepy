// Copyright (c) 2022 Sleepy.

import SwiftUI

@main
struct SleepyApp: App {
    @State var shouldShowNavigationView = false
    @State var checkedPermission = false
    @State var shouldShowLoadingView = true

    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                if shouldShowLoadingView {
                    LoadingAppView()
                } else {
                    if shouldShowNavigationView {
                        MainNavigationView()
                    } else {
                        NeedHealthAccessView()
                    }
                }
            }
            .onAppear {
                HealthManager.shared.checkReadPermissions(type: .activeBurnedEnergy) { access, _ in
                    if access {
                        HealthManager.shared.checkReadPermissions(type: .heart) { access, _ in
                            if access {
                                shouldShowNavigationView = true
                            }
                            shouldShowLoadingView = false
                        }
                    } else {
                        shouldShowLoadingView = false
                    }
                }
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
