import SwiftUI

struct CardWithChartView<T: View>: View {
    private let colorProvider: ColorSchemeProvider
    private let systemImageName: String
    private let titleText: String
    private let mainTitleText: String
    private let chartView: T
    private let bottomView: T

    init(colorProvider: ColorSchemeProvider, systemImageName: String, titleText: String, mainTitleText: String, chartView: T, bottomView: T) {
        self.colorProvider = colorProvider
        self.systemImageName = systemImageName
        self.titleText = titleText
        self.mainTitleText = mainTitleText
        self.chartView = chartView
        self.bottomView = bottomView
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                CardTitleView(colorProvider: colorProvider, systemImageName: systemImageName,
                              titleText: titleText,
                              mainText: mainTitleText,
                              titleColor: .black)

                chartView
                    .padding(.top, 8)

                bottomView
            }
        }
    }
}
