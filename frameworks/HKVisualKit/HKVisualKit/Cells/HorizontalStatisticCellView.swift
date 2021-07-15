//
//  HorizontalStatisticCellView.swift
//  HKVisualKit
//
//  Created by Никита Казанцев on 04.07.2021.
//

import SwiftUI

struct HorizontalStatisticCellView: View {

    private var data: [StatisticsCell]
    private var backgroundColor: Color

    init(data: [StatisticsCell], backgroundColor: Color) {
        self.data = data
        self.backgroundColor = backgroundColor
    }

    var body: some View {
        VStack(spacing: 16) {
            ForEach(data, id: \.self) { cellInfo in
                HStack {
                    Text(cellInfo.title)
                        .padding(.leading, 16)

                    Spacer()

                    Text(cellInfo.value)
                }
            }
        }
        .roundedCardBackground(color: backgroundColor)
    }
    
}

struct StatisticsCell: Hashable {
    let title: String
    let value: String
}

struct HorizontalStatisticCellView_Previews: PreviewProvider {
    static var previews: some View {
        HorizontalStatisticCellView(data: [StatisticsCell(title: "title", value: "value"),StatisticsCell(title: "title", value: "value")], backgroundColor: .gray)
    }
}
