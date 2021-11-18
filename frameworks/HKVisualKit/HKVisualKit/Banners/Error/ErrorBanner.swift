import SwiftUI

public struct ErrorBanner: View {

    // MARK: - Properties

    private let config: ErrorBannerConfig

    public var body: some View {
        CardTitleView(config: config.cardTitleConfig)
    }

    // MARK: - Init

    public init(
        config: ErrorBannerConfig
    ) {
        self.config = config
    }

}

fileprivate struct ErrorBanner_Previews: PreviewProvider {
    static var previews: some View {
        ErrorBanner(config:
                        ErrorBannerConfig(
                            reason: .emptyData(type: .energy),
                            colorProvider: ColorSchemeProvider()
                        )
        )
    }
}
