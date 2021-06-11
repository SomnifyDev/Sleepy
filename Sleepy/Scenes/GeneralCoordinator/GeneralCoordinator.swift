import Foundation
import SwiftUI
import XUI

enum HomeTab {
    case main
    case history
    case alarm
    case settings
}

protocol GeneralCoordinator: ViewModel {

    var tab: HomeTab { get set }

    var mainCoordinator: FeedNavigationCoordinator! { get }

    var openedURL: URL? { get set }

    func startDeepLink(from url: URL)

    func open(_ url: URL)

}

extension GeneralCoordinator {

    @DeepLinkableBuilder
    var children: [DeepLinkable] {
        mainCoordinator
        //historyCoordinator
    }

}
