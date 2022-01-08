// Copyright (c) 2021 Sleepy.

import Armchair
import Foundation
import SettingsKit
import SwiftUI
import UIComponents
import XUI

struct SettingsCoordinatorView: View {
	@Store var viewModel: SettingsCoordinator

	var body: some View {
		NavigationView {
			List {
				Section(header: HeaderView(text: "Health", imageName: "heart.circle")) {
					Stepper(String(format: "Sleep goal %@", Date.minutesToClearString(minutes: self.viewModel.sleepGoalValue)),
					        value: self.$viewModel.sleepGoalValue,
					        in: 360 ... 720,
					        step: 15) { _ in
						self.viewModel.saveSetting(with: self.viewModel.sleepGoalValue, forKey: SleepySettingsKeys.sleepGoal.rawValue)
					}
				}

				Section(header: HeaderView(text: "Feedback", imageName: "person.2")) {
					LabeledButton(text: "Rate us",
					              showChevron: true,
					              action: { Armchair.rateApp() })
					LabeledButton(text: "Share about us",
					              showChevron: true,
					              action: { self.viewModel.isSharePresented = true })
						.sheet(isPresented: self.$viewModel.isSharePresented,
						       content: {
						       	// TODO: replace with ours website
						       	ActivityViewController(activityItems: [URL(string: "https://www.apple.com")!])
						       })
				}.disabled(true)

				Section(header: HeaderView(text: "Sound Recording", imageName: "mic.circle")) {
					Stepper(String(format: "Bitrate – %d", self.viewModel.bitrateValue),
					        value: self.$viewModel.bitrateValue,
					        in: 1000 ... 44000,
					        step: 1000) { _ in
						self.viewModel.saveSetting(with: self.viewModel.bitrateValue, forKey: SleepySettingsKeys.soundBitrate.rawValue)
					}

					Stepper(String(format: "Min. confidence %d", self.viewModel.recognisionConfidenceValue),
					        value: self.$viewModel.recognisionConfidenceValue,
					        in: 10 ... 95,
					        step: 5) { _ in
						self.viewModel.saveSetting(with: self.viewModel.recognisionConfidenceValue, forKey: SleepySettingsKeys.soundRecognisionConfidence.rawValue)
					}
				}

				Section(header: HeaderView(text: "Icon", imageName: "app")) {
					ScrollView(.horizontal, showsIndicators: false) {
						HStack(spacing: 16) {
							ForEach(SettingsCoordinator.IconType.allCases, id: \.self) { iconType in
								VStack {
									Image(iconType.rawValue)
										.resizable()
										.frame(width: 60, height: 60)
										.cornerRadius(12)
										.overlay(
											RoundedRectangle(cornerRadius: 12)
												.stroke(ColorsRepository.Calendar.calendarCurrentDate,
												        lineWidth: self.viewModel.currentIconType == iconType ? 6 : 0)
										)
								}
								.padding(.vertical, 8)
								.onTapGesture { self.viewModel.setIcon(iconType: iconType) }
							}
						}
					}
				} // .frame(height: 45)
			}
			.listStyle(.insetGrouped)
			.navigationBarTitle("Settings", displayMode: .large)
			.onAppear {
				viewModel.getAllValuesFromUserDefaults()
				viewModel.retrieveCurrentIcon()
			}
		}
	}
}

private struct LabeledButton: View {
	let text: String
	let showChevron: Bool
	let action: () -> Void

	var body: some View {
		HStack {
			Button {
				action()
			} label: {
				HStack {
					Text(text)

					if showChevron {
						Spacer()
						Image(systemName: "chevron.right")
					}
				}
				.frame(maxWidth: .infinity, alignment: .leading)
			}
			.buttonStyle(PlainButtonStyle())
		}
	}
}
