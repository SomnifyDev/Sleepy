import SwiftUI

/// Элемент для графика банка сна
/// Параметры:
///     - sleepPercentage: процент сна за конкретный день, для которого нужно построить элемент
struct SleepBankElementView: View {

    private let standartHeight: Double = 100
    private let cornerRadius: Double = 50
    private let opacity: Double = 0.1
    private let sleepPercentage: Double
    private let color: Color

    init(sleepPercentage: Double, color: Color) {
        self.sleepPercentage = sleepPercentage
        self.color = color
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(Color(.black).opacity(opacity))
                .frame(height: standartHeight)
                .cornerRadius(cornerRadius)

            Rectangle()
                .fill(color)
                .frame(height: min(sleepPercentage, standartHeight))
                .cornerRadius(cornerRadius)
        }
    }
}

struct SleepBankElementView_Previews: PreviewProvider {
    static var previews: some View {
        SleepBankElementView(sleepPercentage: 70, color: .green)
    }
}
