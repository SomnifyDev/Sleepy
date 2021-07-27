import Foundation
import SwiftUI

enum SummaryViewCardType: String {
    case heart
    case general
    case phases
}

extension SummaryViewCardType: Identifiable {
    var id: Self { self }
}

class CardService {

    // MARK: Stored Properties - Cards
    private let mainCard: SummaryViewCardType = .general
    private let phasesCard: SummaryViewCardType = .phases
    private let heartCard: SummaryViewCardType = .heart

    // MARK: Iternal functions

    func fetchCard(id: String, _ completion: @escaping (SummaryViewCardType?) -> Void) {
        fetchCards { cards in
            completion( cards.first )
        }
    }

    func fetchCards(_ completion: @escaping ([SummaryViewCardType]) -> Void) {
        completion(
            Mirror(reflecting: self)
                .children
                .compactMap { ($0.value as? SummaryViewCardType) }
        )
    }

}
