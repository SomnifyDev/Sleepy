import SwiftUI

public struct AdviceBanner: View {

    // MARK: - Properties

    @State private var shouldShowAdvice: Bool = false

    private let config: AdviceBannerConfig

    public var body: some View {
        if shouldShowAdvice {
            VStack(spacing: 8) {
                CardTitleView(config: config.cardTitleConfig)
                getAdviceImage()
            }
            .frame(minWidth: 0)
        }
    }

    // MARK: - Init

    public init(
        config: AdviceBannerConfig
    ) {
        self.config = config
        shouldShowAdvice = checkIfAdviceWasNotClosedBefore()
    }

    // MARK: - Private methods

    private func checkIfAdviceWasNotClosedBefore() -> Bool {
        return UserDefaults.standard.object(forKey: config.adviceType.rawValue) == nil
    }

    @ViewBuilder
    private func getAdviceImage() -> some View {
        config.adviceImage
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 80)
            .padding(.all, 8)
            .background(Color.gray.opacity(0.08))
            .cornerRadius(12)
    }

}

struct AdviceBanner_Previews: PreviewProvider {
    static var previews: some View {
        AdviceBanner(
            config: AdviceBannerConfig(
                adviceType: .wearMore,
                adviceImage: Image(systemName: "zzz"),
                colorProvider: ColorSchemeProvider()
            )
        )
    }
}
