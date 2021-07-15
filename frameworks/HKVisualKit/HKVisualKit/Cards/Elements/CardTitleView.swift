import SwiftUI

public struct CardTitleView: View {

    @State private var totalHeight = CGFloat.zero // variant for ScrollView/List
    // = CGFloat.infinity - variant for VStack

    private let colorProvider: ColorSchemeProvider
    private let systemImageName: String
    private let titleText: String
    private let mainText: String?
    private let titleColor: Color
    private let showChevron: Bool

    public init(colorProvider: ColorSchemeProvider, systemImageName: String, titleText: String, mainText: String?, titleColor: Color, showChevron: Bool = false) {
        self.colorProvider = colorProvider
        self.systemImageName = systemImageName
        self.titleText = titleText
        self.mainText = mainText
        self.titleColor = titleColor
        self.showChevron = showChevron
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

                        if showChevron {
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color(.black).opacity(0.25))
                        }
                    }

                    if let mainText = mainText {
                        Text(mainText)
                            .cardDescriptionTextModifier(color: colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)))
                    }

                    Divider()
                        .padding(.top, 4)
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
        CardTitleView(colorProvider: ColorSchemeProvider(), systemImageName: "zzz", titleText: "Title", mainText: "Вот основнvые данные о вашем !!!!!!!!!", titleColor: .blue, showChevron: true)
    }
}