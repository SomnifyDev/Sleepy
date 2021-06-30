import SwiftUI

/// График банка сна
/// Параметры:
///     - points: значения в процентах по каждому из 14 дней для построения графика
struct SleepBankChartView: View {

    let points: [Double]

    var body: some View {
        GeometryReader { geometry in

            let elementWidth: CGFloat = 14
            let spacing: CGFloat = (geometry.size.width - CGFloat(points.count) * elementWidth) / 13.0

            HStack (spacing: spacing) {
                ForEach(0 ..< points.count, id: \.self) { index in
                    SleepBankElementView(sleepPercentage: points[index], color: .green)
                }
            }
        }
    }
}

struct SleepBankChartView_Previews: PreviewProvider {
    static var previews: some View {
        SleepBankChartView(points: [])
    }
}
