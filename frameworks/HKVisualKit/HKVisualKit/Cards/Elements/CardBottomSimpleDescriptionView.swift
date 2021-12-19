// Copyright (c) 2021 Sleepy.

import SwiftUI

public struct CardBottomSimpleDescriptionView: View
{
    @State private var totalHeight = CGFloat.zero // variant for ScrollView/List
    // = CGFloat.infinity - variant for VStack

    private let descriptionText: Text
    private let colorProvider: ColorSchemeProvider
    private let showChevron: Bool

    public init(descriptionText: Text, colorProvider: ColorSchemeProvider, showChevron: Bool = false)
    {
        self.descriptionText = descriptionText
        self.colorProvider = colorProvider
        self.showChevron = showChevron
    }

    public var body: some View
    {
        VStack
        {
            GeometryReader
            { _ in
                VStack(alignment: .leading)
                {
                    HStack
                    {
                        descriptionText
                            .cardBottomTextModifier(color: colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)))

                        Spacer()

                        if showChevron
                        {
                            Image(systemName: "chevron.right")
                        }

                    }.padding(.top, 4)
                }.background(viewHeightReader($totalHeight))
            }
        }
        .frame(height: totalHeight) // - variant for ScrollView/List
        // .frame(maxHeight: totalHeight) - variant for VStack
    }

    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View
    {
        return GeometryReader
        { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async
            {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}

// struct CardBottomSimpleDescriptionView_Previews: PreviewProvider {
//    static var previews: some View {
//        CardBottomSimpleDescriptionView(colorProvider: ColorSchemeProvider(), descriptionText: "testtestest testtestest testtestest testtestest testtestest testtestest ")
//    }
// }
