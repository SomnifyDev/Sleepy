// Copyright (c) 2021 Sleepy.

import Foundation
import HKVisualKit
import SwiftUI
import XUI

class IntroCoordinator: ObservableObject, ViewModel
{
    var colorSchemeProvider: ColorSchemeProvider

    init(colorSchemeProvider: ColorSchemeProvider)
    {
        self.colorSchemeProvider = colorSchemeProvider
    }
}
