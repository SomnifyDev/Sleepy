// Copyright (c) 2022 Sleepy.

import SwiftUI
import UIComponents

public struct GeneralSleepInfoCardView: View {
    let viewModel: SummaryGeneralDataViewModel

    public var body: some View {
        VStack {
            CardTitleView(
                with: CardTitleViewModel(
                    leadIcon: Image(systemName: "zzz"),
                    title: "Sleep: general",
                    description: nil,
                    trailIcon: ImageWithOptionalActionView(image: Image(systemName: "chevron.right"), action: nil),
                    trailText: nil,
                    titleColor: ColorsRepository.General.mainSleepy,
                    descriptionColor: nil,
                    shouldShowSeparator: true
                )
            )

            HStack {
                VStack(alignment: .leading, spacing: 22) {
                    HStack(alignment: .center) {
                        Image(systemName: "bed.double")
                            .modifiedImage(
                                with: ColorsRepository.SummaryCard.fallAsleepDuration,
                                size: 23,
                                width: 30
                            )

                        VStack(alignment: .leading) {
                            Text(viewModel.sleepInterval.start.getFormattedDate(format: "HH:mm"))
                                .boldTextModifier(color: ColorsRepository.SummaryCard.fallAsleepDuration)

                            Text("Drop off")
                                .boldTextModifier(
                                    color: ColorsRepository.Text.standard,
                                    size: 14
                                )
                        }
                    }

                    HStack(alignment: .center) {
                        Image(systemName: "timer")
                            .modifiedImage(
                                with: ColorsRepository.SummaryCard.sleepDuration,
                                size: 27.5,
                                width: 30
                            )

                        VStack(alignment: .leading) {
                            Text(viewModel.sleepInterval.end.hoursMinutes(from: viewModel.sleepInterval.start))
                                .boldTextModifier(color: ColorsRepository.SummaryCard.sleepDuration)

                            Text("Sleep duration")
                                .boldTextModifier(
                                    color: ColorsRepository.Text.standard,
                                    size: 14
                                )
                        }
                    }
                }

                Spacer()

                VStack(alignment: .leading, spacing: 22) {
                    HStack(alignment: .center) {
                        Image(systemName: "sunrise.fill")
                            .modifiedImage(
                                with: ColorsRepository.SummaryCard.awake,
                                size: 25,
                                width: 30
                            )

                        VStack(alignment: .leading) {
                            Text(self.viewModel.sleepInterval.end.getFormattedDate(format: "HH:mm"))
                                .boldTextModifier(color: ColorsRepository.SummaryCard.awake)

                            Text("Awake")
                                .boldTextModifier(
                                    color: ColorsRepository.Text.standard,
                                    size: 14
                                )
                        }
                    }

                    HStack(alignment: .center) {
                        Image(systemName: "moon")
                            .modifiedImage(
                                with: ColorsRepository.SummaryCard.moon,
                                size: 27.5,
                                width: 30
                            )

                        VStack(alignment: .leading) {
                            Text(self.viewModel.sleepInterval.start.hoursMinutes(from: viewModel.inbedInterval.start))
                                .boldTextModifier(color: ColorsRepository.SummaryCard.moon)

                            Text("Falling asleep")
                                .boldTextModifier(
                                    color: ColorsRepository.Text.standard,
                                    size: 14
                                )
                        }
                    }
                }
            }
            .padding(.top, 8)
        }
        .frame(minHeight: 0)
    }
}
