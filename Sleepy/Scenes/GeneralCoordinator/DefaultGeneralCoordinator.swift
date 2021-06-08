import Foundation
import XUI

class DefaultGeneralCoordinator: ObservableObject, GeneralCoordinator {

    // MARK: Stored Properties

    @Published var tab = HomeTab.main

    @Published private(set) var mainCoordinator: MainListCoordinator!
    //@Published private(set) var historyCoordinator: HistoryCoordinator!

    @Published var openedURL: URL?

    private let hkStoreService: HKStoreService
    private let cardService: CardService

    // MARK: Initialization

    init(hkStoreService: HKStoreService, cardService: CardService) {
        self.hkStoreService = hkStoreService
        self.cardService = cardService
        
        self.mainCoordinator = DefaultMainListCoordinator(
            title: "main list",
            cardService: cardService,
            parent: self,
            filter: { !$0.title.isEmpty }
        )

        // self.historyCoordinatator = DefaultHistoryCoordinator(...
    }

    // MARK: Methods

    func startDeepLink(from url: URL) {

        guard url.scheme == "cards",
              url.host == "card",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let recipeID = components.queryItems?.first(where: { $0.name == "cardID" })?.value else {
            assertionFailure("Trying to open app with illegal url \(url).")
            return
        }

        openCardForRecipe(id: recipeID)
    }

    func open(_ url: URL) {
        self.openedURL = url
    }

    // MARK: Helpers

    private func openCard(for card: Card) {
        let mainListCoordinator = firstReceiver(as: MainListCoordinator.self, where: { $0.filter(card) })
        mainListCoordinator!.open(card)
    }

    private func openCardForRecipe(id: String) {
        cardService.fetchCard(id: id) { [weak self] recipe in
            guard let recipe = recipe, let self = self else {
                return
            }
            self.openCard(for: recipe)
        }
    }


    private func openCalendar() {
        // logic
    }

}
