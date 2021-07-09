import SwiftUI

public struct ProgressChartView: View {

    @State private var totalHeight = CGFloat.zero // variant for ScrollView/List
    // = CGFloat.infinity - variant for VStack

    var currentWeeksProgress: ProgressItem
    var beforeWeeksProgress: ProgressItem

    public init(currentWeeksProgress: ProgressItem, beforeWeeksProgress: ProgressItem) {
        self.currentWeeksProgress = currentWeeksProgress
        self.beforeWeeksProgress = beforeWeeksProgress
    }

    public var body: some View {
        VStack {
            GeometryReader { geometry in

                VStack(alignment: .leading) {
                    CardTitleView(systemImageName: "person",
                                  titleText: "Title",
                                  mainText: "Thats some progress you've made in several weeks in sleep duration",
                                  titleColor: .blue)

                    ProgressItemView(progressItem: currentWeeksProgress)
                        .padding(.top, 8)
                        .padding(.trailing, currentWeeksProgress.value >  beforeWeeksProgress.value ? 64 : 0)
                        .foregroundColor(.blue)

                    ProgressItemView(progressItem: beforeWeeksProgress)
                        .padding(.top, 8)
                        .padding(.trailing, currentWeeksProgress.value >  beforeWeeksProgress.value ? 64 : 0)
                        .foregroundColor(Color.gray.opacity(0.5))

                    CardBottomSimpleDescriptionView(descriptionText: "Compared to 2 weeks before, you slept \( currentWeeksProgress.value >  beforeWeeksProgress.value ?  "more": "less") by \(abs(currentWeeksProgress.value - beforeWeeksProgress.value)) minutes")
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
    let title: String
    let text: String
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

struct ProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressChartView(currentWeeksProgress: ProgressItem(title: "title", text: "text", value: 320),
                          beforeWeeksProgress: ProgressItem(title: "title", text: "text", value: 360))
    }
}