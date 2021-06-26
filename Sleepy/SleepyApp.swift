import SwiftUI

@main
struct SleepyApp: App {

    // MARK: Stored Properties

    let hkStoreService: HKStoreService
    let cardService: CardService

    @StateObject var coordinator: RootCoordinatorImpl
    @State var hasOpenedURL = false

    // MARK: Initialization

    init() {

        // инициализация сервисов, которые будут необходимы экранам и подэкранам
        hkStoreService = HKStoreService()
        cardService = CardService()

        // инициализация root-ового (главного координатора)
        let coordinator = RootCoordinatorImpl(hkStoreService: hkStoreService, cardService: cardService)
        _coordinator = .init(wrappedValue: coordinator)
    }

    // MARK: Scenes

    var body: some Scene {
        WindowGroup {
            // вью главного координатора (по сути это таб бар)
            RootCoordinatorView(coordinator: coordinator)
            // Handling deeplinks in iOS 14 with onOpenURL
            // https://www.donnywals.com/handling-deeplinks-in-ios-14-with-onopenurl/
            // TODO: make unique urls for Sleepy https://typesafely.substack.com/p/use-link-and-the-onopenurl-modifier
                .onOpenURL { coordinator.startDeepLink(from: $0) }
            // модификатор для дебага. При старте прилы симулируем deepLink
                .onAppear { simulateURLOpening() }
        }
    }

    // MARK: Private functions

    private func simulateURLOpening() {
        // Oftentimes, deep links are implemented using complicated,
        // hard-to-trace chains of commands throughout the entire application.
        // New developers on your team (or even you yourself a couple of months later)
        // will have a hard time understanding when a specific method in this
        // chain is performed and whether it’s actually needed or not.
        //
        // But normally, the user can reach the target view of any deep-link
        // by going through the app manually step-by-step, so why don’t we just
        // simulate these steps by triggering the same actions on our
        // coordinator objects and view models directly?
#if DEBUG
        // небольшая проверочка чтоб не напороться на ситуацию
        // когда после открытия одного диплинка не начать открывать другой диплинк
        guard !hasOpenedURL else {
            return
        }
        hasOpenedURL = true

        self.cardService.fetchCards { cards in
            // выбираем случайную карточку для открытия
            // а точнее формируем ссылку для этого.
            // Почему ссылка? Потому что это как путь до конкретного экрана
            // Хоть тут мы формируем ее константно, но по сути она может быть любой
            //
            // пример:
            // summary:// - открывает экран карточек
            // summary://card?type=heart - открывает детальную карточку сердца
            // summary://card?type=phases - открывает детальную карточку фаз
            // calendar:// - открывает календарь
            // alarm:// - открывает будильник
            // alarm://creation
            guard let cardType = cards.randomElement(),
                  // [tab name]://[element inside name]?[parameter]=value
                  let url = URL(string: "summary://card?type=" + cardType.rawValue) else {
                      assertionFailure("Could not find card or illegal url format.")
                      return
                  }

            // делегируем координатору открытие диплинка
            coordinator.startDeepLink(from: url)
        }
#endif
    }

}
