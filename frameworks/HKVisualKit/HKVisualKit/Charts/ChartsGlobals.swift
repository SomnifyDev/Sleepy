// Copyright (c) 2022 Sleepy.

import Foundation
import SwiftUI

public enum BarType {
    case rectangle(color: Color)
    case circle(color: Color)
    case filled(foregroundElementColor: Color, backgroundElementColor: Color, percentage: Double)
}
