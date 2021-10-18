import SwiftUI

public struct ProgressChartView: View {
    @State private var totalHeight = CGFloat.zero // variant for ScrollView/List
    // = CGFloat.infinity - variant for VStack

    private let titleText: String
    private let mainText: String
    private let systemImage: String
    private let colorProvider: ColorSchemeProvider
    private var currentProgress: ProgressItem
    private var beforeProgress: ProgressItem
    private var analysisString: String
    private let mainColor: Color
    private let mainTextColor: Color

    public init(titleText: String,
                mainText: String,
                systemImage: String,
                colorProvider: ColorSchemeProvider,
                currentProgress: ProgressItem,
                beforeProgress: ProgressItem,
                analysisString: String,
                mainColor: Color,
                mainTextColor: Color)
    {
        self.titleText = titleText
        self.mainText = mainText
        self.systemImage = systemImage
        self.colorProvider = colorProvider
        self.currentProgress = currentProgress
        self.beforeProgress = beforeProgress
        self.analysisString = analysisString
        self.mainColor = mainColor
        self.mainTextColor = mainTextColor
    }

    public var body: some View {
        VStack {
            GeometryReader { _ in

                VStack(alignment: .leading) {
                    CardTitleView(titleText: self.titleText,
                                  mainText: mainText,
                                  leftIcon: Image(systemName: self.systemImage),
                                  titleColor: self.mainColor,
                                  mainTextColor: self.mainTextColor,
                                  colorProvider: self.colorProvider)

                    ProgressItemView(progressItem: currentProgress)
                        .padding(.top, 8)
                        .padding(.trailing, currentProgress.value >= beforeProgress.value ? 0 : 64)
                        .foregroundColor(mainColor)

                    ProgressItemView(progressItem: beforeProgress)
                        .padding(.top, 8)
                        .padding(.trailing, beforeProgress.value >= currentProgress.value ? 0 : 64)
                        .foregroundColor(mainColor.opacity(0.5))

                    CardBottomSimpleDescriptionView(descriptionText: Text(analysisString), colorProvider: colorProvider)
                }.background(viewHeightReader($totalHeight))
            }
        }.frame(height: totalHeight) // - variant for ScrollView/List
        // .frame(maxHeight: totalHeight) - variant for VStack
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

public struct ProgressItem {
    public let title: String
    public let text: String
    public let value: Int

    public init(title: String, text: String, value: Int) {
        self.title = title
        self.text = text
        self.value = value
    }
}

public struct ProgressItemView: View {
    let progressItem: ProgressItem

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(progressItem.title)
                .fontWeight(.semibold)

            HStack {
                ZStack(alignment: .leading) {
                    Rectangle()
                        .cornerRadius(5)

                    Text(progressItem.text)
                        .fontWeight(.medium)
                        .font(.callout)
                        .foregroundColor(.white)
                        .padding(.leading, 8)
                }.frame(height: 30)
            }
        }
    }
}
