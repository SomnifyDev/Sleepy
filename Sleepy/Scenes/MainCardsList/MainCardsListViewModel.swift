import SwiftUI
import XUI
import HKVisualKit

protocol MainCardsListViewModel: ViewModel {

    var title: String { get }
    var cards: [Card] { get }

    func open(_ card: Card)
    
}
