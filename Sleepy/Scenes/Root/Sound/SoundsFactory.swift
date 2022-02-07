// Copyright (c) 2022 Sleepy.

import SwiftUI
import UIComponents

struct SoundsFactory {
    fileprivate enum BannerIdentifiers: String {
        case soundsEmptyBannerIdentifier
    }

    func makeSoundsEmptyBannerViewModel() -> BannerViewModel<CardBottomSimpleDescriptionView> {
        return BannerViewModel(
            with: self.makeSomethingBrokenBannerCardTitleViewModel(),
            bannerIdentifier: BannerIdentifiers.soundsEmptyBannerIdentifier.rawValue
        )
    }

    // MARK: - Private methods

    private func makeSomethingBrokenBannerCardTitleViewModel() -> CardTitleViewModel {
        return CardTitleViewModel(
            leadIcon: IconsRepository.calendar,
            title: "Advice",
            description: "Record your sleep sounds by pressing ‘record’ button below  and get sound-recognision after you end recording",
            trailIcon: IconsRepository.delete,
            trailText: nil,
            titleColor: Color.orange,
            descriptionColor: nil,
            shouldShowSeparator: false
        )
    }
}
