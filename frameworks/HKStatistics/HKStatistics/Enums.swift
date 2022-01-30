// Copyright (c) 2021 Sleepy.

import Foundation

public enum Indicator: String {
	case min
	case max
	case mean
	case sum
}

public enum MetricsData {
	case rmssd
	case ssdn
}

public enum NumericData {
	case heart
	case energy
	case respiratory
}

public enum SleepData {
	case asleep
	case inBed
	case fallAsleepDuration
}

public enum PhasesData {
	case chart
	case deepPhaseDuration
	case lightPhaseDuration
}

public enum SleepInterval {
	case inbed
	case asleep
}
