//
//  WelcomeScreenLineView.swift
//  Sleepy
//
//  Created by Никита Казанцев on 26.09.2021.
//

import HKVisualKit
import SwiftUI

struct WelcomeScreenLineView: View {
    var title: String
    var subTitle: String
    var imageName: String
    var color: Color

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: self.imageName)
                    .font(.title)
                    .frame(width: 16, height: 16)
                    .foregroundColor(self.color)
                    .padding()

                VStack(alignment: .leading) {
                    Text(self.title)
                        .font(.title3)
                        .foregroundColor(.primary)

                    Text(self.subTitle)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }.padding(.top)
        }
    }
}
