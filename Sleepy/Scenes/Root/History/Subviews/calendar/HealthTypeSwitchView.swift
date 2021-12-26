// Copyright (c) 2021 Sleepy.

import Armchair
import SettingsKit
import SwiftUI
import HKCoreSleep
import UIComponents

struct HealthTypeSwitchView: View {
	@State private var totalHeight = CGFloat.zero // << variant for ScrollView/List
	//    = CGFloat.infinity   // << variant for VStack
	@Binding var selectedType: HealthType

	var body: some View {
		VStack {
			GeometryReader { geometry in
				self.generateContent(in: geometry)
			}
		}
		.frame(height: totalHeight) // << variant for ScrollView/List
		// .frame(maxHeight: totalHeight) // << variant for VStack
	}

	private func generateContent(in g: GeometryProxy) -> some View {
		var width = CGFloat.zero
		var height = CGFloat.zero

		return ZStack(alignment: .topLeading) {
			ForEach(HealthType.allCases, id: \.self) { tag in
				self.item(for: tag)
					.padding([.horizontal, .vertical], 4)
					.alignmentGuide(.leading, computeValue: { d in
						if abs(width - d.width) > g.size.width {
							width = 0
							height -= d.height
						}

						let result = width

						if tag == HealthData.allCases.last! {
							width = 0
						} else {
							width -= d.width
						}
						return result
					})
					.alignmentGuide(.top, computeValue: { _ in
						let result = height
						if tag == HealthData.allCases.last! {
							height = 0
						}
						return result
					})
			}
		}.background(self.viewHeightReader($totalHeight))
	}

	private func item(for type: HealthType) -> some View {
		Text(self.getItemDescription(for: type))
			.healthTypeSwitchTextModifier()
			.background(type == self.selectedType
				? self.getSelectedItemColor(for: type)
                        : ColorsRepository.Calendar.emptyDay)
			.cornerRadius(12)
			.onTapGesture {
				selectedType = type
				let date = Date(timeIntervalSince1970: UserDefaults.standard.double(forKey: "armchair_important_calendar_event"))

				if date.getDayInt() != Date().getDayInt() {
					UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "armchair_important_calendar_event")

					DispatchQueue.main.asyncAfter(deadline: .now() + 7.5) {
						Armchair.userDidSignificantEvent(true)
					}
				}
			}
	}

	private func getSelectedItemColor(for type: HealthType) -> Color {
		switch type {
		case .heart:
            return ColorsRepository.Heart.heart
		case .energy:
			return ColorsRepository.Heart.energy
		case .asleep, .inbed:
            return ColorsRepository.Phase.lightSleep
		case .respiratory:
			return Color(.systemBlue)
		}
	}

	private func getItemDescription(for type: HealthType) -> String {
		switch type {
		case .heart:
			return "Heart rate"
		case .energy:
			return "Energy waste"
		case .asleep:
			return "Sleep duration"
		case .respiratory:
			return "Respiratory"
		case .inbed:
			return "In bed duration"
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
