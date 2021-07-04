//
//  CardBottomDescriptionView.swift
//  HKVisualKit
//
//  Created by Никита Казанцев on 04.07.2021.
//

import SwiftUI

public struct CardBottomSimpleDescriptionView: View {

    @State private var totalHeight = CGFloat.zero // variant for ScrollView/List
    // = CGFloat.infinity - variant for VStack
    
    var descriptionText: String

    public var body: some View {
        VStack {
            GeometryReader { geometry in
                VStack(alignment: .leading,spacing: 4) {
                    Divider()
                        .padding(.top, 4)

                    Text(descriptionText)
                        .fixedSize(horizontal: false, vertical: true)
                }.background(viewHeightReader($totalHeight))
            }
        }.frame(height: totalHeight)
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

struct CardBottomSimpleDescriptionView_Previews: PreviewProvider {
    static var previews: some View {
        CardBottomSimpleDescriptionView(descriptionText: "testtestest testtestest testtestest testtestest testtestest testtestest ")
    }
}
