//
//  CardBottomDescriptionView.swift
//  HKVisualKit
//
//  Created by Никита Казанцев on 04.07.2021.
//

import SwiftUI

public struct CardBottomSimpleDescriptionView: View {

    private let colorProvider: ColorSchemeProvider
    @State private var totalHeight = CGFloat.zero // variant for ScrollView/List
    // = CGFloat.infinity - variant for VStack
    private let descriptionText: Text

    public init(colorProvider: ColorSchemeProvider, descriptionText: Text) {
        self.colorProvider = colorProvider
        self.descriptionText = descriptionText
    }

    public var body: some View {
        VStack {
            GeometryReader { geometry in
                VStack(alignment: .leading, spacing: 4) {
                    Divider()
                        .padding(.top, 4)

                    descriptionText
                        .cardBottomTextModifier(color: colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)))

                }.background(viewHeightReader($totalHeight))
            }
        }
        .frame(height: totalHeight) // - variant for ScrollView/List
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

//struct CardBottomSimpleDescriptionView_Previews: PreviewProvider {
//    static var previews: some View {
//        CardBottomSimpleDescriptionView(colorProvider: ColorSchemeProvider(), descriptionText: "testtestest testtestest testtestest testtestest testtestest testtestest ")
//    }
//}
