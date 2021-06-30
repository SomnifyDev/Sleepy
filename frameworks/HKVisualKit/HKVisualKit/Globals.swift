import Foundation

// MARK: Health

public enum HealthData: CaseIterable {
    case heart
    case energy
    case sleep
    case inbed
}

// MARK: Colors

public enum ColorType {

    case general(GeneralColors)
    case card(CardColors)
    case phases(PhasesColors)
    case heart(HeartColors)
    case calendar(CalendarColors)
    case genInfoCardColors(GenInfoCardColors)

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
    }

    public enum PhasesColors {
        case wakeUpColor
        case lightSleepColor
        case deepSleepColor
    }

    public enum HeartColors {
        case heartColor
    }

    public enum GenInfoCardColors {
        case awakeColor
        case moonColor
    }

}
