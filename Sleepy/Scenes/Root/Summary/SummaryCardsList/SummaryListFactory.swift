import SwiftUI
import UIComponents

fileprivate enum BannerIdentifiers: String {
    case summaryCardsListSomethingBrokenBannerIdentifier
}

struct SummaryListFactory {

    // MARK: - Methods

    func makeSomethingBrokenBannerViewModel() -> BannerViewModel<CardTitleView> {
        return BannerViewModel(
            with: makeSomethingBrokenBannerCardTitleViewModel(),
            bannerIdentifier: BannerIdentifiers.summaryCardsListSomethingBrokenBannerIdentifier.rawValue
        )
    }

    func makePhasesCardTitleViewModel() -> CardTitleViewModel {
        return CardTitleViewModel(
            leadIcon: IconsRepository.sleep,
            title: "Phases",
            description: "Here is some info about phases of your last sleep",
            trailIcon: nil,
            trailText: nil,
            titleColor: ColorsRepository.Phase.deepSleep,
            descriptionColor: ColorsRepository.Text.secondary,
            shouldShowSeparator: true
        )
    }

    func makeHeartCardTitleViewModel() -> CardTitleViewModel {
        return CardTitleViewModel(
            leadIcon: IconsRepository.heartFilled,
            title: "Heart",
            description: "Here is some info about heart rate of your last sleep",
            trailIcon: nil,
            trailText: nil,
            titleColor: ColorsRepository.Heart.heart,
            descriptionColor: ColorsRepository.Text.secondary,
            shouldShowSeparator: true
        )
    }

    func makeRespiratoryCardTitleViewModel() -> CardTitleViewModel {
        return CardTitleViewModel(
            leadIcon: IconsRepository.lungs,
            title: "Respiratory rate",
            description: "Here is some info about respiratory rate of your last sleep",
            trailIcon: nil,
            trailText: nil,
            titleColor: Color.blue,
            descriptionColor: ColorsRepository.Text.secondary,
            shouldShowSeparator: true
        )
    }

    // MARK: - Private methods

    private func makeSomethingBrokenBannerCardTitleViewModel() -> CardTitleViewModel {
        return CardTitleViewModel(
            leadIcon: IconsRepository.exclamationMarkSquareFilled,
            title: "Data empty or restricted",
            description: nil,
            trailIcon: ImageWithOptionalActionView(
                image: IconsRepository.delete,
                action: {
                    UserDefaults.standard.set(true, forKey: BannerIdentifiers.summaryCardsListSomethingBrokenBannerIdentifier.rawValue)
                }
            ),
            trailText: nil,
            titleColor: Color.red,
            descriptionColor: nil,
            shouldShowSeparator: false
        )
    }
    
}
