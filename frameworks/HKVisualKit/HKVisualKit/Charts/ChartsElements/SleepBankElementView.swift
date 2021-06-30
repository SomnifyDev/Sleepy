import SwiftUI

/// Элемент для графика банка сна
/// Параметры:
///     - sleepPercentage: процент сна за конкретный день, для которого нужно построить элемент
struct SleepBankElementView: View {

    private let standartHeight: Double = 100
    private let standartWidth: Double = 14
    private let cornerRadius: Double = 50
    private let opacity: Double = 0.1

    let sleepPercentage: Double
    let color: Color

    var body: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(Color(.black).opacity(opacity))
                .frame(width: standartWidth, height: standartHeight)
                .cornerRadius(cornerRadius)

            Rectangle()
                .fill(color)
                .frame(width: standartWidth, height: min(sleepPercentage, standartHeight))
                .cornerRadius(cornerRadius)
        }
    }
}

struct SleepBankElementView_Previews: PreviewProvider {
    static var previews: some View {
        SleepBankElementView(sleepPercentage: 50, color: .green)
    }
}
