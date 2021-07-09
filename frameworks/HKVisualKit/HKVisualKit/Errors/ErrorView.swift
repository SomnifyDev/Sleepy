import SwiftUI

public struct ErrorView: View {
    
    public enum ErrorType: Equatable {
        
        case emptyData(type: HealthData)
        case brokenData(type: HealthData)
        
        public static func ==(lhs: ErrorType, rhs: ErrorType) -> Bool {
            switch (lhs, rhs) {
            case (brokenData, brokenData):
                return true
            case (.emptyData,.emptyData):
                return true
            default:
                return false
            }
        }
        
    }

    // MARK: Private properties
    
    public let errorType: ErrorType
    public let colorScheme: SleepyColorScheme
    
    private var iconName: String = ""
    private var titleText: String = ""
    private var dataText: String = ""

    // MARK: Init

    public init(errorType: ErrorType, colorScheme: SleepyColorScheme) {
        self.errorType = errorType
        self.colorScheme = colorScheme
        
        titleText = getTitleText()
        dataText = getDataText()
        iconName = getIconName()
    }
    
    public var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 8) {
                
                // TODO: make images and text vary base on errorType
                HStack {
                    Image(systemName: getIconName())
                        .foregroundColor(colorScheme.getColor(of: .heart(.heartColor)))
                    Text("titleText")
                        .fontWeight(.bold)
                        .foregroundColor(colorScheme.getColor(of: .heart(.heartColor)))
                    Spacer()
                }
                .padding(.top, 4)
                .padding(.leading, 16)
                
                HStack {
                    Text(getDataText())
                        .bold()
                        .minimumScaleFactor(0.01)
                    Spacer()
                }
                .padding(.top, 4)
                .padding(.bottom, 4)
                .padding(.leading, 16)
                .padding(.trailing, 16)
                
            }
            .frame(width: geometry.size.width)
            .foregroundColor(colorScheme.getColor(of: .heart(.heartColor)))
        }
    }
    
    // MARK: Private Methods
    
    private func getTitleText() -> String {
         return "data empty"
    }
    
    private func getDataText() -> String {
        return "data empty"
    }
    
    private func getIconName() -> String {
        // TODO: add switch for different data states
        return "person"
    }
    
}

public struct ErrorView_Previews: PreviewProvider {
    public static var previews: some View {
        ErrorView(errorType: .brokenData(type: .heart),
                  colorScheme: SleepyColorScheme())
    }
}
