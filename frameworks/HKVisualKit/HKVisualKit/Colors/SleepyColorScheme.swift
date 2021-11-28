// Copyright (c) 2021 Sleepy.

import Foundation
import SwiftUI

// MARK: - Protocol

public protocol HKApplicationColorScheme {
	func getColor(of type: ColorType) -> Color
}

public final class SleepyColorScheme: HKApplicationColorScheme {
	// general
	private let appBackgroundColor: Color
	private let mainSleepyColor: Color
	private let healthColor: Color

	// cards
	private let cardBackgroundColor: Color

	// calendar
	private let emptyDayColor: Color
	private let negativeDayColor: Color
	private let neutralDayColor: Color
	private let positiveDayColor: Color
	private let calendarCurrentDateColor: Color

	// phases
	private let wakeUpColor: Color
	private let lightSleepColor: Color
	private let deepSleepColor: Color

	// heart
	private let heartColor: Color

	// energy
	private let energyColor: Color

	// genInfoCard
	private let awakeColor: Color
	private let moonColor: Color
	private let sleepDurationColor: Color
	private let fallAsleepDurationColor: Color

	// texts
	private let standartText: Color
	private let secondaryText: Color
	private let adviceText: Color
	// charts
	private let verticalProgressChartElementColor: Color

	init() {
		self.appBackgroundColor = Color("backgroundColor")
		self.mainSleepyColor = Color("mainColor")
		self.healthColor = Color("healthColor")
		self.cardBackgroundColor = Color("cardsBackground")
		self.emptyDayColor = Color("calendarEmptyColor")
		self.negativeDayColor = Color("calendarNegativityColor")
		self.neutralDayColor = Color("calendarNeutralColor")
		self.positiveDayColor = Color("calendarPositivityColor")
		self.calendarCurrentDateColor = Color("calendarCurrentDateColor")
		self.wakeUpColor = Color("wakingColor")
		self.lightSleepColor = Color("lightSleepColor")
		self.deepSleepColor = Color("deepSleepColor")
		self.heartColor = Color("heartColor")
		self.awakeColor = Color("awakeColor")
		self.moonColor = Color("moonColor")
		self.energyColor = Color("energyColor")
		self.standartText = Color("SleepyStandartTexts")
		self.secondaryText = Color("SecondaryText")
		self.adviceText = Color("AdviceText")
		self.sleepDurationColor = Color("sleepDurationColor")
		self.fallAsleepDurationColor = Color("fallAsleepDurationColor")
		self.verticalProgressChartElementColor = Color("VerticalProgressChartElementBackground")
	}

	// MARK: Public methods

	public func getColor(of type: ColorType) -> Color {
		switch type {
		// general
		case .general(.appBackgroundColor):
			return self.appBackgroundColor
		case .general(.healthColor):
			return self.healthColor
		case .general(.mainSleepyColor):
			return self.mainSleepyColor

		// card
		case .card(.cardBackgroundColor):
			return self.cardBackgroundColor

		// phases
		case .phases(.deepSleepColor):
			return self.deepSleepColor
		case .phases(.lightSleepColor):
			return self.lightSleepColor
		case .phases(.wakeUpColor):
			return self.wakeUpColor

		// heart
		case .heart(.heartColor):
			return self.heartColor

		// energy
		case .energy(.energyColor):
			return self.energyColor

		// calendar
		case .calendar(.emptyDayColor):
			return self.emptyDayColor
		case .calendar(.negativeDayColor):
			return self.negativeDayColor
		case .calendar(.neutralDayColor):
			return self.neutralDayColor
		case .calendar(.positiveDayColor):
			return self.positiveDayColor
		case .calendar(.calendarCurrentDateColor):
			return self.calendarCurrentDateColor

		// general info card
		case .summaryCardColors(.awakeColor):
			return self.awakeColor
		case .summaryCardColors(.moonColor):
			return self.moonColor
		case .summaryCardColors(.sleepDurationColor):
			return self.sleepDurationColor
		case .summaryCardColors(.fallAsleepDurationColor):
			return self.fallAsleepDurationColor

		// texts
		case .textsColors(.standartText):
			return self.standartText
		case .textsColors(.secondaryText):
			return self.secondaryText
		case .chartColors(.verticalProgressChartElement):
			return self.verticalProgressChartElementColor
		case .textsColors(.adviceText):
			return self.adviceText
		}
	}
}
