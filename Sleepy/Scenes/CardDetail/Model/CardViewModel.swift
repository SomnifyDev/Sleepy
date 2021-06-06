import Foundation
import XUI

protocol CardViewModel: ViewModel {

    var card: Card { get }

    func open(_ url: URL)
    
}
