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

class IntroCoordinator: ObservableObject, ViewModel {
    var colorSchemeProvider: ColorSchemeProvider

    init(colorSchemeProvider: ColorSchemeProvider) {
        self.colorSchemeProvider = colorSchemeProvider
    }
}
