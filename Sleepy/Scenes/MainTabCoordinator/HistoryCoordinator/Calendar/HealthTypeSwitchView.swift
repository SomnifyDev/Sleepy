import SwiftUI
import HKVisualKit

struct HealthTypeSwitchView: View {

    @Binding var selectedType: HealthData

    var colorScheme: SleepyColorScheme
    @State private var totalHeight = CGFloat.zero // << variant for ScrollView/List
    //    = CGFloat.infinity   // << variant for VStack

    var body: some View {
        VStack {
            GeometryReader { geometry in
                self.generateContent(in: geometry)
            }
        }
        .frame(height: totalHeight)// << variant for ScrollView/List
        //.frame(maxHeight: totalHeight) // << variant for VStack
    }

    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(HealthData.allCases, id: \.self) { tag in
                self.item(for: tag)
                    .padding([.horizontal, .vertical], 4)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > g.size.width) {
                            width = 0
                            height -= d.height
                        }

                        let result = width

                        if tag == HealthData.allCases.last! {
                            width = 0 //last item
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: {d in
                        let result = height
                        if tag == HealthData.allCases.last! {
                            height = 0 // last item
                        }
                        return result
                    })
            }
        }.background(viewHeightReader($totalHeight))
    }

    private func item(for type: HealthData) -> some View {
        Text(getItemDescription(for: type))
            .padding(.all, 6)
            .font(.body)
            .foregroundColor(type == selectedType  ? .white : .black)
            .background(type == selectedType
                        ? getSelectedItemColor(for: type)
                        : colorScheme.getColor(of: .calendar(.emptyDayColor)))
            .cornerRadius(12)
            .onTapGesture {
                selectedType = type
            }
    }

    private func getSelectedItemColor(for type: HealthData) -> Color {
        switch type {
        case .heart:
            return colorScheme.getColor(of: .heart(.heartColor))
        case .energy:
            return colorScheme.getColor(of: .energy(.energyColor))
        case .sleep:
            return colorScheme.getColor(of: .general(.mainSleepyColor))
        case .inbed:
            return colorScheme.getColor(of: .general(.mainSleepyColor))
        }
    }

    private func getItemDescription(for type: HealthData) -> String {
        switch type {
        case .heart:
            return "heart rate"
        case .energy:
            return "energy wasted"
        case .sleep:
            return "sleep duration"
        case .inbed:
            return "inbed duration"
        }
    }

    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}
