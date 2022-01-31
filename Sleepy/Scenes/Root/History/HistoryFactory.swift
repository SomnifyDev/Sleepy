// Copyright (c) 2022 Sleepy.

import SwiftUI
import UIComponents

struct HistoryFactory {
    func makeSsdnCardTitleViewModel() -> CardTitleViewModel {
        return CardTitleViewModel(
            leadIcon: IconsRepository.heartFilled,
            title: "SSDN",
            description: "SDNN reflects all the cyclic components responsible for variability in the period of recording, therefore it represents total variability",
            trailIcon: nil,
            trailText: nil,
            titleColor: ColorsRepository.Heart.heart,
            descriptionColor: ColorsRepository.Text.standard,
            shouldShowSeparator: true
        )
    }
}
