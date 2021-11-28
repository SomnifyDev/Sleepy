// Copyright (c) 2021 Sleepy.

import Foundation

// MARK: Health

public enum HealthData: String, CaseIterable {
	case heart
	case energy
	case respiratory
	case asleep
	case inbed
}

// MARK: Colors

public enum ColorType {
	case general(GeneralColors)
	case card(CardColors)
	case phases(PhasesColors)
	case heart(HeartColors)
	case energy(EnergyColors)
	case calendar(CalendarColors)
	case summaryCardColors(SummaryCardColors)
	case textsColors(TextsColors)
	case chartColors(ChartColors)

	public enum GeneralColors {
		case appBackgroundColor
		case mainSleepyColor
		case healthColor
	}

	public enum CardColors {
		case cardBackgroundColor
	}

	public enum CalendarColors {
		case emptyDayColor
		case negativeDayColor
		case neutralDayColor
		case positiveDayColor
		case calendarCurrentDateColor
	}

	public enum PhasesColors {
		case wakeUpColor
		case lightSleepColor
		case deepSleepColor
	}

	public enum HeartColors {
		case heartColor
	}

	public enum EnergyColors {
		case energyColor
	}

	public enum SummaryCardColors {
		case awakeColor
		case moonColor
		case sleepDurationColor
		case fallAsleepDurationColor
	}

	public enum TextsColors {
		case standartText
		case secondaryText
		case adviceText
	}

	public enum ChartColors {
		case verticalProgressChartElement
	}
}
