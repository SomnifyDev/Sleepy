// Copyright (c) 2022 Sleepy.

import Foundation
import UIComponents
import XUI

class AlarmCoordinator: ObservableObject, ViewModel {
    @Published var openedURL: URL?
    private unowned let parent: RootCoordinator

    init(parent: RootCoordinator) {
        self.parent = parent
    }

    func open(_ url: URL) {
        self.openedURL = url
    }
}
