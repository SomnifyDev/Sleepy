//
//  StandartChartElement.swift
//  HKVisualKit
//
//  Created by Анас Бен Мустафа on 6/29/21.
//

import SwiftUI

/// Стандартный элемент графика (фазы, сердце)
/// Параметры:
///     - width: ширина элемента
///     - height: высота элементе
///     - color: цвет отображения
struct StandartChartElementView: View {

    private let cornerRadius: Double = 50

    let width: CGFloat
    let height: CGFloat
    let color: Color

    var body: some View {
        Rectangle()
            .foregroundColor(color)
            .frame(width: width, height: height)
            .cornerRadius(cornerRadius)
    }
}

struct StandartChartElementView_Previews: PreviewProvider {
    static var previews: some View {
        StandartChartElementView(width: 15, height: 30, color: .green)
    }
}
