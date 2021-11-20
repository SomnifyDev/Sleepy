// Copyright (c) 2021 Sleepy.

import HKVisualKit
import SwiftUI
import XUI

struct SummaryCardsListView: View {
	@Store var viewModel: SummaryCardsListCoordinator

	@EnvironmentObject var cardService: CardService

	var body: some View {
		GeometryReader { _ in
			ZStack {
				viewModel.colorProvider.sleepyColorScheme.getColor(of: .general(.appBackgroundColor))
					.edgesIgnoringSafeArea(.all)

				ScrollView {
					VStack(alignment: .center) {
						// TODO: почему не изменяется нигде
						if viewModel.somethingBroken {
							BannerView(bannerViewType: .advice(type: .wearMore,
							                                   imageSystemName: "wearAdvice"),
							           colorProvider: viewModel.colorProvider)
								.roundedCardBackground(
									color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor))
								)
						}

						// MARK: General

						if let generalViewModel = cardService.generalViewModel {
							SectionNameTextView(text: "Sleep information".localized,
							                    color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)))
								.padding(.top)

							GeneralSleepInfoCardView(viewModel: generalViewModel,
							                         colorProvider: viewModel.colorProvider)
								.roundedCardBackground(
									color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor))
								)
								.onNavigation {
									viewModel.open(.general)
								}
								.buttonStyle(PlainButtonStyle())
						} else {
							BannerView(bannerViewType: .brokenData(type: .asleep),
							           colorProvider: viewModel.colorProvider)
								.roundedCardBackground(
									color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor))
								)
						}

						SectionNameTextView(text: "Sleep session".localized,
						                    color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)))

						// MARK: Phases

						if let phasesViewModel = cardService.phasesViewModel,
						   let generalViewModel = cardService.generalViewModel
						{
							CardWithChartView(colorProvider: viewModel.colorProvider,
							                  systemImageName: "sleep",
							                  titleText: "Phases".localized,
							                  mainTitleText: "Here is some info about phases of your last sleep".localized,
							                  titleColor: viewModel.colorProvider.sleepyColorScheme.getColor(of: .phases(.deepSleepColor)),
							                  showChevron: true,
							                  chartView: StandardChartView(colorProvider: viewModel.colorProvider,
							                                               chartType: .phasesChart,
							                                               chartHeight: 75,
							                                               points: phasesViewModel.phasesData,
							                                               dateInterval: generalViewModel.sleepInterval),
							                  bottomView: CardBottomSimpleDescriptionView(descriptionText:
							                  	Text(
							                  		String(format: "Duration of light phase was %@, while the duration of deep sleep was %@".localized, phasesViewModel.timeInLightPhase, phasesViewModel.timeInDeepPhase)
							                  	),
							                  	colorProvider: viewModel.colorProvider))
								.roundedCardBackground(color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))
								.onNavigation {
									viewModel.open(.phases)
								}
								.buttonStyle(PlainButtonStyle())
						} else {
							BannerView(bannerViewType: .emptyData(type: .asleep),
							           colorProvider: viewModel.colorProvider)
								.roundedCardBackground(color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))

							CardWithChartView<StandardChartView, EmptyView>(colorProvider: viewModel.colorProvider,
							                                                color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .phases(.deepSleepColor)),
							                                                chartType: .phasesChart)
								.roundedCardBackground(color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))
								.blur(radius: 4)
						}

						SectionNameTextView(text: "Heart rate".localized,
						                    color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)))

						// MARK: Heart

						if let heartViewModel = cardService.heartViewModel,
						   let generalViewModel = cardService.generalViewModel
						{
							CardWithChartView(colorProvider: viewModel.colorProvider,
							                  systemImageName: "suit.heart.fill",
							                  titleText: "Heart".localized,
							                  mainTitleText: "Here is some info about heart rate of your last sleep".localized,
							                  titleColor: viewModel.colorProvider.sleepyColorScheme.getColor(of: .heart(.heartColor)),
							                  showChevron: true,
							                  chartView: StandardChartView(colorProvider: viewModel.colorProvider,
							                                               chartType: .defaultChart(
							                                               	barType: .circle(color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .heart(.heartColor)))
							                                               ),
							                                               chartHeight: 75,
							                                               points: heartViewModel.heartRateData,
							                                               dateInterval: generalViewModel.sleepInterval),
							                  bottomView: CardBottomSimpleDescriptionView(descriptionText:
							                  	Text(
							                  		String(format: "The maximal heartbeat was %@ bpm while the minimal was %@".localized, heartViewModel.minHeartRate, heartViewModel.maxHeartRate)
							                  	),
							                  	colorProvider: viewModel.colorProvider))
								.roundedCardBackground(
									color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor))
								)
								.onNavigation {
									viewModel.open(.heart)
								}
								.buttonStyle(PlainButtonStyle())
						} else {
							BannerView(bannerViewType: .emptyData(type: .heart),
							           colorProvider: viewModel.colorProvider)
								.roundedCardBackground(
									color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor))
								)

							CardWithChartView<StandardChartView, EmptyView>(colorProvider: viewModel.colorProvider,
							                                                color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .heart(.heartColor)),
							                                                chartType: .defaultChart(barType: .circle(color: Color.red)))
								.roundedCardBackground(
									color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor))
								)
								.blur(radius: 4)
						}

						// MARK: Respiratory

						if let respiratoryViewModel = cardService.respiratoryViewModel,
						   let generalViewModel = cardService.generalViewModel
						{
							CardWithChartView(colorProvider: viewModel.colorProvider,
							                  systemImageName: "lungs",
							                  titleText: "Respiratory rate".localized,
							                  mainTitleText: "Here is some info about respiratory rate of your last sleep".localized,
							                  titleColor: Color(.systemBlue),
							                  showChevron: true,
							                  chartView: StandardChartView(colorProvider: viewModel.colorProvider,
							                                               chartType: .defaultChart(
							                                               	barType: .rectangle(
							                                               		color: Color(.systemBlue)
							                                               	)
							                                               ),
							                                               chartHeight: 75,
							                                               points: respiratoryViewModel.respiratoryRateData,
							                                               dateInterval: generalViewModel.sleepInterval),
							                  bottomView: CardBottomSimpleDescriptionView(descriptionText:
							                  	Text(
							                  		String(format: "The maximal respiratory rate was %@ while the minimal was %@".localized,
							                  		       respiratoryViewModel.minRespiratoryRate,
							                  		       respiratoryViewModel.maxRespiratoryRate)
							                  	),
							                  	colorProvider: viewModel.colorProvider))
								.roundedCardBackground(
									color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor))
								)
								.onNavigation {
									viewModel.open(.breath)
								}
								.buttonStyle(PlainButtonStyle())
						} else {
							BannerView(bannerViewType: .emptyData(type: .respiratory),
							           colorProvider: viewModel.colorProvider)
								.roundedCardBackground(
									color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor))
								)

							CardWithChartView<StandardChartView, EmptyView>(colorProvider: viewModel.colorProvider,
							                                                color: Color(.systemBlue),
							                                                chartType: .defaultChart(
							                                                	barType: .rectangle(
							                                                		color: Color(.systemBlue)
							                                                	)
							                                                ))
							.roundedCardBackground(color: viewModel.colorProvider.sleepyColorScheme.getColor(of: .card(.cardBackgroundColor)))
							.blur(radius: 4)
						}
					}
				}
			}
		}
		.navigationTitle("\("Summary".localized), \((self.cardService.generalViewModel?.sleepInterval.end ?? Date()).getFormattedDate(format: "MMM d"))")
		.onAppear { self.viewModel.sendAnalytics(cardService: self.cardService) }
	}
}
