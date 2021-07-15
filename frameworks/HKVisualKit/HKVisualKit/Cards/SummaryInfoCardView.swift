import SwiftUI

public struct SummaryInfoCardView: View {

    @State private var totalHeight = CGFloat.zero // variant for ScrollView/List
    // = CGFloat.infinity - variant for VStack

    private let colorProvider: ColorSchemeProvider
    private let sleepStartTime: String
    private let sleepDuration: String
    private let awakeTime: String
    private let fallingAsleepDuration: String

    public init(colorProvider: ColorSchemeProvider, sleepStartTime: String, sleepDuration: String, awakeTime: String, fallingAsleepDuration: String) {
        self.colorProvider = colorProvider
        self.sleepStartTime = sleepStartTime
        self.sleepDuration = sleepDuration
        self.awakeTime = awakeTime
        self.fallingAsleepDuration = fallingAsleepDuration
    }

    public var body: some View {
        VStack {
            GeometryReader { geometry in
                VStack {

                    CardTitleView(colorProvider: colorProvider,
                                  systemImageName: "zzz",
                                  titleText: "Sleep: general",
                                  mainText: "Here is the info about your last sleep.",
                                  titleColor: colorProvider.sleepyColorScheme.getColor(of: .general(.mainSleepyColor)))

                    HStack {
                        VStack(alignment: .leading, spacing: 22) {
                            HStack(alignment: .center) {
                                Image(systemName: "bed.double")
                                    .summaryCardImage(color: colorProvider.sleepyColorScheme.getColor(of: .summaryCardColors(.fallAsleepDurationColor)),
                                                      size: 23,
                                                      width: 30)

                                VStack(alignment: .leading) {
                                    Text(sleepStartTime)
                                        .boldTextModifier(color: colorProvider.sleepyColorScheme.getColor(of: .summaryCardColors(.fallAsleepDurationColor)))

                                    Text("Drop off")
                                        .boldTextModifier(color: colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)),
                                                          size: 14)
                                }
                            }

                            HStack(alignment: .center) {
                                Image(systemName: "timer")
                                    .summaryCardImage(color: colorProvider.sleepyColorScheme.getColor(of: .summaryCardColors(.sleepDurationColor)),
                                                      size: 27.5, width: 30)

                                VStack(alignment: .leading) {
                                    Text(sleepDuration)
                                        .boldTextModifier(color: colorProvider.sleepyColorScheme.getColor(of: .summaryCardColors(.sleepDurationColor)))

                                    Text("Sleep duration")
                                        .boldTextModifier(color: colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)),
                                                          size: 14)
                                }
                            }
                        }

                        Spacer()

                        VStack(alignment: .leading, spacing: 22) {
                            HStack(alignment: .center) {
                                Image(systemName: "sunrise.fill")
                                    .summaryCardImage(color: colorProvider.sleepyColorScheme.getColor(of: .summaryCardColors(.awakeColor)),
                                                      size: 25,
                                                      width: 30)

                                VStack(alignment: .leading) {
                                    Text(awakeTime)
                                        .boldTextModifier(color: colorProvider.sleepyColorScheme.getColor(of: .summaryCardColors(.awakeColor)))

                                    Text("Awake")
                                        .boldTextModifier(color: colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)),
                                                          size: 14)
                                }
                            }

                            HStack(alignment: .center) {
                                Image(systemName: "moon")
                                    .summaryCardImage(color: colorProvider.sleepyColorScheme.getColor(of: .summaryCardColors(.moonColor)),
                                                      size: 27.5, width: 30)

                                VStack(alignment: .leading) {
                                    Text(fallingAsleepDuration)
                                        .boldTextModifier(color: colorProvider.sleepyColorScheme.getColor(of: .summaryCardColors(.moonColor)))

                                    Text("Falling asleep")
                                        .boldTextModifier(color: colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)),
                                                          size: 14)
                                }
                            }
                        }
                    }
                }
                .background(viewHeightReader($totalHeight))
            }
        }.frame(height: totalHeight) // - variant for ScrollView/List
        //.frame(maxHeight: totalHeight) - variant for VStack
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
