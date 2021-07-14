import SwiftUI

public struct SummaryInfoCardView: View {

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
        GeometryReader { geometry in
            VStack {
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

                                Text("Average pulse")
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
        }
    }
}
