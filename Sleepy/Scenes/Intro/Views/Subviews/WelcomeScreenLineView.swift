// Copyright (c) 2022 Sleepy.

import SwiftUI
import UIComponents

struct WelcomeScreenLineView: View {
    private var title: String
    private var subTitle: String
    private var imageName: String
    private var color: Color

    init(title: String, subTitle: String, imageName: String, color: Color) {
        self.title = title
        self.subTitle = subTitle
        self.imageName = imageName
        self.color = color
    }

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
