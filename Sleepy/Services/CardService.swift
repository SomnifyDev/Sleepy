import Foundation
import SwiftUI

enum CardType: String {
    case heart
    case general
    case phases
}

extension CardType: Identifiable {
    var id: Self { self }
}

class CardService {

    // MARK: Stored Properties - Cards

    private let mainCard: CardType = .general

    private let phasesCard: CardType = .phases

    private let heartCard: CardType = .heart

    // MARK: Iternal functions

    func fetchCard(id: String, _ completion: @escaping (CardType?) -> Void) {
        fetchCards { cards in
            completion( cards.first )
        }
    }

    func fetchCards(_ completion: @escaping ([CardType]) -> Void) {
        completion(
            Mirror(reflecting: self)
                .children
                .compactMap { ($0.value as? CardType) }
        )
    }

}
