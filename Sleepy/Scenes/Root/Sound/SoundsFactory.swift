//
//  SoundsFactory.swift
//  Sleepy
//
//  Created by Никита Казанцев on 16.01.2022.
//

import UIComponents
import SwiftUI

struct SoundsFactory {
    fileprivate enum BannerIdentifiers: String {
        case soundsEmptyBannerIdentifier
    }

    func makeSoundsEmptyBannerViewModel() -> BannerViewModel<CardBottomSimpleDescriptionView> {
        return BannerViewModel(
            with: makeSomethingBrokenBannerCardTitleViewModel(),
            bannerIdentifier: BannerIdentifiers.soundsEmptyBannerIdentifier.rawValue
        )
    }

    // MARK: - Private methods

    private func makeSomethingBrokenBannerCardTitleViewModel() -> CardTitleViewModel {
        return CardTitleViewModel(
            leadIcon: IconsRepository.calendar,
            title: "Advice",
            description: "Record your sleep sounds by pressing ‘record’ button below  and get sound-recognision after you end recording",
            trailIcon: ImageWithOptionalActionView(
                image: IconsRepository.delete,
                action: {
                    UserDefaults.standard.set(true, forKey: BannerIdentifiers.soundsEmptyBannerIdentifier.rawValue)
                }
            ),
            trailText: nil,
            titleColor: Color.orange,
            descriptionColor: nil,
            shouldShowSeparator: false
        )
    }
}
