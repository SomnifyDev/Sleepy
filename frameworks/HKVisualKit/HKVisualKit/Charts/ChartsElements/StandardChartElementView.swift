import SwiftUI

/// Элемент стандартного графика
/// - Parameters:
///  - width: ширина элемента
///  - height: высота элементе
///  - color: цвет отображения
struct StandardChartElementView: View {

    private let cornerRadius: Double = 50
    private let width: CGFloat
    private let height: CGFloat
    private let type: BarType

    init(width: CGFloat, height: CGFloat, type: BarType) {
        self.width = width
        self.height = height
        self.type = type
    }

    var body: some View {
        VStack {

            switch type {
            case .rectangle(let color):
                Rectangle()
                    .foregroundColor(color)
                    .cornerRadius(cornerRadius)
                
            case .circle(let color):
                Circle()
                    .foregroundColor(color)
                Spacer()

            case .filled(let foregroundElementColor, let backgroundElementColor, let percentage):
                ZStack(alignment: .bottom) {
                    Rectangle()
                        .fill(backgroundElementColor)
                        .cornerRadius(cornerRadius)

                    Rectangle()
                        .fill(foregroundElementColor)
                        .frame(height: min(height * percentage, height))
                        .cornerRadius(cornerRadius)
                }
            }
        }.frame(width: width, height: height)
    }
    
}
