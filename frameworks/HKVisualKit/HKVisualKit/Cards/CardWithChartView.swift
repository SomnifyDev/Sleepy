import SwiftUI

public struct CardWithChartView<T: View, U: View>: View {

    @State private var totalHeight = CGFloat.zero // variant for ScrollView/List
    // = CGFloat.infinity - variant for VStack

    private let colorProvider: ColorSchemeProvider
    private let systemImageName: String
    private let titleText: String
    private let mainTitleText: String
    private let titleColor: Color
    private let showChevron: Bool
    private let chartView: T
    private let bottomView: U

    public init(colorProvider: ColorSchemeProvider, systemImageName: String, titleText: String, mainTitleText: String, titleColor: Color, showChevron: Bool, chartView: T, bottomView: U) {
        self.colorProvider = colorProvider
        self.systemImageName = systemImageName
        self.titleText = titleText
        self.mainTitleText = mainTitleText
        self.titleColor = titleColor
        self.showChevron = showChevron
        self.chartView = chartView
        self.bottomView = bottomView
    }

    public var body: some View {
        VStack {
            GeometryReader { geometry in
                VStack(alignment: .leading) {
                    CardTitleView(colorProvider: colorProvider,
                                  systemImageName: systemImageName,
                                  titleText: titleText,
                                  mainText: mainTitleText,
                                  titleColor: titleColor,
                                  showChevron: showChevron)

                    chartView
                        .padding(.top, 8)

                    bottomView
                }
                .background(viewHeightReader($totalHeight))
            }
        }.frame(height: totalHeight) // - variant for ScrollView/List
        //.frame(maxHeight: totalHeight) - variant for VStack
    }

    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}
