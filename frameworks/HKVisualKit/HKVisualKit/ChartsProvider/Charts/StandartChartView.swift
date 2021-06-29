//
//  StandartChartView.swift
//  HKVisualKit
//
//  Created by Анас Бен Мустафа on 6/29/21.
//

import SwiftUI

/// Стандартный график (для фаз, сердца)
/// Параметры:
///     - points: значения для элементов графика
///     - color: цвет отображения
struct StandartChartView: View {

    private let maxHeight: CGFloat = 80
    private let spacing: CGFloat = 3

    let points: [Double]
    let color: Color

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: spacing) {
                ForEach(0 ..< points.count, id: \.self) { index in

                    let width = abs((geometry.size.width - spacing * CGFloat(points.count - 1))) / CGFloat(points.count)
                    let height = maxHeight * (points[index] / points.max()!)

                    StandartChartElementView(width: width, height: height, color: color)
                }
            }
        }
    }
}

struct StandartChartView_Previews: PreviewProvider {
    static var previews: some View {
        StandartChartView(points: [], color: .red)
    }
}
