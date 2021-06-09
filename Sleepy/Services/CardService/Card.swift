import Foundation
import SwiftUI

enum CardType {
    case heart
    case general
    case phases
}

struct Card: Identifiable {

    // MARK: Stored Properties

    var id = UUID()
    var type: CardType
//    var imageURL: URL?
    var title: String
//    var ingredients: [String]
//    var steps: [String]
//    var isVegetarian: Bool
    var source: URL?

}
