import SwiftUI

@main
struct SleepyApp: App {

    // MARK: Stored Properties

    let hkStoreService: HKStoreService
    let cardService: CardService

    @StateObject var coordinator: DefaultGeneralCoordinator
    @State var hasOpenedURL = false

    // MARK: Initialization

    init() {
        hkStoreService = HKStoreService()
        cardService = CardService()
        let coordinator = DefaultGeneralCoordinator(hkStoreService: hkStoreService, cardService: cardService)
        _coordinator = .init(wrappedValue: coordinator)
    }

    // MARK: Scenes

    var body: some Scene {
        WindowGroup {
            GeneralCoordinatorView(coordinator: coordinator)
                .onOpenURL { coordinator.startDeepLink(from: $0) }
                .onAppear { simulateURLOpening() }
        }
    }

    // MARK: Helpers

    private func simulateURLOpening() {
        #if DEBUG
        guard !hasOpenedURL else {
            return
        }
        hasOpenedURL = true

        self.cardService.fetchCards { cards in
            guard let card = cards.randomElement(),
                  let url = URL(string: "cards://card?cardID=" + card.id.uuidString) else {
                assertionFailure("Could not find recipe or illegal url format.")
                return
            }

            coordinator.startDeepLink(from: url)
        }
        #endif
    }

}
