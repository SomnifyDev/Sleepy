import Foundation
import SwiftUI

class CardService {

    // MARK: Stored Properties - Recipes

    private let mainCard = Card(title: "gen card")

    private let phasesCard = Card(title: "phases card")

    private let heartCard = Card(title: "heart card")

    func fetchCard(id: String, _ completion: @escaping (Card?) -> Void) {
        fetchCards { recipes in
            completion(recipes.first { $0.id.uuidString == id })
        }
    }

    func fetchCards(_ completion: @escaping ([Card]) -> Void) {
        completion(
            Mirror(reflecting: self)
                .children
                .compactMap { $0.value as? Card }
                .sorted(by: { $0.title < $1.title })
        )
    }

}
