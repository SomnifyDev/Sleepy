import SwiftUI

public struct CardTitleView: View {

    @State private var totalHeight = CGFloat.zero // variant for ScrollView/List
    // = CGFloat.infinity - variant for VStack

    private let colorProvider: ColorSchemeProvider
    private let systemImageName: String
    private let titleText: String
    private let navigationText: String?
    private let mainText: String?
    private let titleColor: Color
    private let mainTextColor: Color
    private let showChevron: Bool
    private let showSeparator: Bool

    public init(colorProvider: ColorSchemeProvider,
                systemImageName: String,
                titleText: String,
                mainText: String? = nil,
                navigationText: String? = nil,
                titleColor: Color,
                mainTextColor: Color,
                showSeparator: Bool = true,
                showChevron: Bool = false) {
        self.colorProvider = colorProvider
        self.systemImageName = systemImageName
        self.titleText = titleText
        self.mainText = mainText
        self.mainTextColor = mainTextColor
        self.navigationText = navigationText
        self.titleColor = titleColor
        self.showChevron = showChevron
        self.showSeparator = showSeparator
    }

    public var body: some View {
        VStack {
            GeometryReader { geometry in
                VStack(alignment: .leading,spacing: 4) {
                    HStack {
                        Image(systemName: systemImageName)
                            .foregroundColor(titleColor)

                        Text(titleText)
                            .cardTitleTextModifier(color: titleColor)

                        Spacer()

                        if let navigationText = navigationText {
                            Text(navigationText)
                                .cardTitleTextModifier(color: titleColor)
                                .lineLimit(1)
                        }

                        if showChevron {
                            Image(systemName: "chevron.right")
                                .foregroundColor(titleColor)
                        }
                    }

                    if let mainText = mainText {
                        Text(mainText)
                            .foregroundColor(mainTextColor)
                    }

                    if showSeparator {
                        Divider()
                            .padding(.top, 4)
                    }
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

struct CardTitleView_Previews: PreviewProvider {
    static var previews: some View {
        CardTitleView(colorProvider: ColorSchemeProvider(), systemImageName: "zzz", titleText: "Title", mainText: "Вот основнvые данные о вашем !!!!!!!!!", titleColor: .blue, mainTextColor: .red, showChevron: true)
    }
}
