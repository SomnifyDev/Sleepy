import SwiftUI

public struct ErrorView: View {
    
    public enum ErrorType: Equatable {
        
        case emptyData(type: HealthData)
        case brokenData(type: HealthData)
        case restrictedData(type: HealthData)

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

    @State private var totalHeight = CGFloat.zero // variant for ScrollView/List
    // = CGFloat.infinity - variant for VStack
    
    private let errorType: ErrorType
    private let colorProvider: ColorSchemeProvider
    
    private var iconName: String = ""
    private var titleText: String = ""
    private var dataText: String = ""

    // MARK: Init

    public init(errorType: ErrorType, colorProvider: ColorSchemeProvider) {
        self.errorType = errorType
        self.colorProvider = colorProvider
        
        titleText = getTitleText()
        dataText = getDataText()
        iconName = getIconName()
    }
    
    public var body: some View {
        VStack {
            GeometryReader { geometry in
                VStack(spacing: 8) {

                    CardTitleView(colorProvider: colorProvider,
                                  systemImageName: self.getIconName(),
                                  titleText: "Error occured".localized,
                                  mainText: getDataText(),
                                  navigationText: "Read FAQ".localized,
                                  titleColor: self.colorProvider.sleepyColorScheme.getColor(of: .heart(.heartColor)),
                                  mainTextColor: self.colorProvider.sleepyColorScheme.getColor(of: .textsColors(.standartText)),
                                  showSeparator: false,
                                  showChevron: true)

                }
                .frame(width: geometry.size.width)
                .background(viewHeightReader($totalHeight))
            }
        }
        .frame(height: totalHeight) // - variant for ScrollView/List
        //.frame(maxHeight: totalHeight) - variant for VStack
    }
    
    // MARK: Private Methods

    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
    
    private func getTitleText() -> String {
        return "data empty".localized
    }
    
    private func getDataText() -> String {
        switch self.errorType {
        case .emptyData(type: let type):
            return String(format: "No data of type %@ was recieved".localized, type.rawValue)
        case .brokenData(type: let type):
            return String(format: "There was not enought data to display your %@ charts. Try to sleep with Apple Watch More".localized, type.rawValue)
        case .restrictedData(type: let type):
            return String(format: "Sleepy was restricted from reading your %@ data. Fix that in your settings".localized, type.rawValue)
        }
    }
    
    private func getIconName() -> String {
        switch self.errorType {
        case .emptyData(type: _), .brokenData(type: _):
            return "exclamationmark.square.fill"
        case .restrictedData(type: _):
            return "eye.slash.fill"
        }
    }
    
}

public struct ErrorView_Previews: PreviewProvider {
    public static var previews: some View {
        ErrorView(errorType: .brokenData(type: .heart),
                  colorProvider: ColorSchemeProvider())
    }
}
