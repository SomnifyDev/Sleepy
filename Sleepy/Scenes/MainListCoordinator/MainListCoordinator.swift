import SwiftUI
import XUI

protocol MainListCoordinator: ViewModel {

    var viewModel: MainCardsListViewModel! { get }
    var detailViewModel: CardViewModel? { get set }

    func filter(_ card: Card) -> Bool

    func open(_ card: Card)
    func open(_ url: URL)
}

extension MainListCoordinator {

    @DeepLinkableBuilder
    var children: [DeepLinkable] {
        viewModel
        detailViewModel
    }

}
