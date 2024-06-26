// Copyright (c) 2022 Sleepy.

import Foundation
import UIComponents

struct SummaryPhasesDataViewModel {
    let phasesData: [ChartPointDisplayItem]
    let timeInLightPhase: String
    let timeInDeepPhase: String
    let mostIntervalInLightPhase: String
    let mostIntervalInDeepPhase: String
}
