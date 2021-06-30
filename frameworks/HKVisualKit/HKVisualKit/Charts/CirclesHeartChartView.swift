//
//  CirclesHeartChartView.swift
//  HKVisualKit
//
//  Created by Анас Бен Мустафа on 6/29/21.
//

import SwiftUI

/// График с кружочками (для сердца)
/// /// Параметры:
///     - points: значения для элементов графика
///     - color: цвет отображения
struct CirclesChartView: View {

    let points: [Double]
    let color: Color

    var body: some View {
        GeometryReader { geometry in

            let circleWidth: CGFloat = 15
            let spacing = (geometry.size.width - circleWidth * CGFloat(points.count)) / CGFloat(points.count - 1)

            HStack (spacing: spacing) {

                let min = points.min()!
                let max = points.max()!
                let mean = (max + min) / 2.0

                ForEach(0 ..< points.count, id: \.self) { index in
                    CircleChartElementView(max: max, min: min, mean: mean, current: points[index], circleColor: .red)
                }
            }
        }
    }
}

struct CirclesChartView_Previews: PreviewProvider {
    static var previews: some View {
        CirclesChartView(points: [], color: .red)
    }
}
