// Copyright (c) 2022 Sleepy.

import SwiftUI
import UIComponents

struct SummaryListFactory {
    fileprivate enum BannerIdentifiers: String {
        case summaryCardsListSomethingBrokenBannerIdentifier
    }

    // MARK: - Methods

    func makeSomethingBrokenBannerViewModel() -> BannerViewModel<CardBottomSimpleDescriptionView> {
        return BannerViewModel(
            with: self.makeSomethingBrokenBannerCardTitleViewModel(),
            bannerIdentifier: BannerIdentifiers.summaryCardsListSomethingBrokenBannerIdentifier.rawValue
        )
    }

    func makePhasesCardTitleViewModel() -> CardTitleViewModel {
        return CardTitleViewModel(
            leadIcon: IconsRepository.sleep,
            title: "Phases",
            description: "Here is some info about phases of your last sleep",
            trailIcon: IconsRepository.chevronRight,
            trailText: nil,
            titleColor: ColorsRepository.Phase.deepSleep,
            descriptionColor: ColorsRepository.Text.standard,
            shouldShowSeparator: true
        )
    }

    func makeHeartCardTitleViewModel() -> CardTitleViewModel {
        return CardTitleViewModel(
            leadIcon: IconsRepository.heartFilled,
            title: "Heart",
            description: "Here is some info about heart rate of your last sleep",
            trailIcon: IconsRepository.chevronRight,
            trailText: nil,
            titleColor: ColorsRepository.Heart.heart,
            descriptionColor: ColorsRepository.Text.standard,
            shouldShowSeparator: true
        )
    }

    func makeRespiratoryCardTitleViewModel() -> CardTitleViewModel {
        return CardTitleViewModel(
            leadIcon: IconsRepository.lungs,
            title: "Respiratory rate",
            description: "Here is some info about respiratory rate of your last sleep",
            trailIcon: IconsRepository.chevronRight,
            trailText: nil,
            titleColor: Color.blue,
            descriptionColor: ColorsRepository.Text.standard,
            shouldShowSeparator: true
        )
    }

    // MARK: - Private methods

    private func makeSomethingBrokenBannerCardTitleViewModel() -> CardTitleViewModel {
        return CardTitleViewModel(
            leadIcon: IconsRepository.exclamationMarkSquareFilled,
            title: "Data empty or restricted",
            description: "Check health permissions in settings / wear apple watch while you sleep",
            trailIcon: nil,
            trailText: nil,
            titleColor: Color.red,
            descriptionColor: nil,
            shouldShowSeparator: false
        )
    }
}
