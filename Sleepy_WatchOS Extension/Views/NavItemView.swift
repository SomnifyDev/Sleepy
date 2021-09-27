//
//  NavItemView.swift
//  Sleepy_WatchOS Extension
//
//  Created by Анас Бен Мустафа on 9/27/21.
//

import SwiftUI

struct NavItemView: View {
    var imageName: String
    var title: String
    var titleColor: Color
    var mainInfo: String
    var bottomTitle: String

    var body: some View {
        HStack {
            VStack (alignment: .leading, spacing: 2) {
                HStack {
                    Image(systemName: imageName)
                        .foregroundColor(titleColor)
                        .font(.system(size: 12))
                    Text(title)
                        .foregroundColor(titleColor)
                        .font(.system(size: 12))
                }
                Text(mainInfo)
                    .font(.title2)
                Text(bottomTitle)
                    .font(.system(size: 14))
                    .opacity(0.6)
            }
            .padding()
            Spacer()
            Image(systemName: "chevron.forward")
                .foregroundColor(.white)
                .opacity(0.5)
                .padding(.trailing)
        }
    }
}

struct NavItemView_Previews: PreviewProvider {
    static var previews: some View {
        NavItemView(
            imageName: "zzz",
            title: "Title",
            titleColor: .blue,
            mainInfo: "Main info",
            bottomTitle: "Bottom title"
        )
    }
}
