//
//  IntroCoordinator.swift
//  IntroCoordinator
//
//  Created by Никита Казанцев on 25.09.2021.
//

import Foundation
import HKVisualKit
import SwiftUI
import XUI

enum PageTab: String {
    case first
    case features
    case settings
}

class IntroCoordinator: ObservableObject, ViewModel {
    @Published var tab = PageTab.first

    var colorSchemeProvider: ColorSchemeProvider

    init(colorSchemeProvider: ColorSchemeProvider) {
        self.colorSchemeProvider = colorSchemeProvider
    }
}
