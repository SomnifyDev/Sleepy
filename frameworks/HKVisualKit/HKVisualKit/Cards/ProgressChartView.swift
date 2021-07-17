import SwiftUI

public struct ProgressChartView: View {

    @State private var totalHeight = CGFloat.zero // variant for ScrollView/List
    // = CGFloat.infinity - variant for VStack

    private let titleText: String
    private let mainText: String
    private let systemImage: String
    private let colorProvider: ColorSchemeProvider
    private var currentWeeksProgress: ProgressItem
    private var beforeWeeksProgress: ProgressItem
    private var analysisString: String
    private let mainColor: Color

    public init(titleText: String,
                mainText: String,
                systemImage: String,
                colorProvider: ColorSchemeProvider,
                currentWeeksProgress: ProgressItem,
                beforeWeeksProgress: ProgressItem,
                analysisString: String,
                mainColor: Color) {
        self.titleText = titleText
        self.mainText = mainText
        self.systemImage = systemImage
        self.colorProvider = colorProvider
        self.currentWeeksProgress = currentWeeksProgress
        self.beforeWeeksProgress = beforeWeeksProgress
        self.analysisString = analysisString
        self.mainColor = mainColor
    }

    public var body: some View {
        VStack {
            GeometryReader { geometry in

                VStack(alignment: .leading) {
                    CardTitleView(colorProvider: colorProvider, systemImageName: systemImage,
                                  titleText: titleText,
                                  mainText: mainText,
                                  titleColor: mainColor)

                    ProgressItemView(progressItem: currentWeeksProgress)
                        .padding(.top, 8)
                        .padding(.trailing, currentWeeksProgress.value > beforeWeeksProgress.value ? 0 : 64)
                        .foregroundColor(mainColor)

                    ProgressItemView(progressItem: beforeWeeksProgress)
                        .padding(.top, 8)
                        .padding(.trailing, beforeWeeksProgress.value > currentWeeksProgress.value ? 0 : 64)
                        .foregroundColor(mainColor.opacity(0.5))

                    CardBottomSimpleDescriptionView(descriptionText: Text(analysisString), colorProvider: colorProvider)
                }.background(viewHeightReader($totalHeight))
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

//struct ProgressView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProgressChartView(colorProvider: ColorSchemeProvider(), currentWeeksProgress: ProgressItem(title: "title", text: "text", value: 320),
//                          beforeWeeksProgress: ProgressItem(title: "title", text: "text", value: 360),
//                          analysisString: "sleep analysis here",
//                          mainColor: Color(UIColor.yellow))
//    }
//}
