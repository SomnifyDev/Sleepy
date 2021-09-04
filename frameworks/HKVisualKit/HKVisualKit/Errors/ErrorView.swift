import SwiftUI

public struct ErrorView: View {

    public enum AdviceType {
        case wearMore
        case soundRecording
        case some
    }
    
    public enum ErrorType: Equatable {
        
        case emptyData(type: HealthData)
        case brokenData(type: HealthData)
        case restrictedData(type: HealthData)
        case advice(type: AdviceType, imageSystemName: String? = nil)

        public static func ==(lhs: ErrorType, rhs: ErrorType) -> Bool {
            switch (lhs, rhs) {
            case (brokenData, brokenData):
                return true
            case (.emptyData,.emptyData):
                return true
            case (.restrictedData, .restrictedData):
                return true
            case (.advice, .advice):
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

    @State private var viewDidClose = false

    // MARK: Init

    public init(errorType: ErrorType, colorProvider: ColorSchemeProvider) {
        self.errorType = errorType
        self.colorProvider = colorProvider
        
        titleText = getTitleText()
        dataText = getDataText()
        iconName = getIconName()
    }
    
    public var body: some View {
        if !viewDidClose {
        VStack {
            GeometryReader { geometry in
                VStack(spacing: 8) {

                        CardTitleView(titleText: self.titleText,
                                      mainText: self.dataText,
                                      leftIcon: Image(systemName: self.iconName),
                                      rightIcon: Image(systemName: "xmark.circle"),
                                      titleColor: errorType == .advice(type: .some, imageSystemName: "")
                                      ? self.colorProvider.sleepyColorScheme.getColor(of: .textsColors(.adviceText))
                                      : self.colorProvider.sleepyColorScheme.getColor(of: .heart(.heartColor)),
                                      mainTextColor: self.colorProvider.sleepyColorScheme.getColor(of: .textsColors(.secondaryText)),
                                      showSeparator: errorType == .advice(type: .some, imageSystemName: ""),
                                      colorProvider: self.colorProvider,
                                      onCloseTapAction: {
                            viewDidClose.toggle()
                        })

                        if errorType == .advice(type: .some, imageSystemName: ""),
                           let imageSystemName = self.getImageSystemName() {
                            Image(imageSystemName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 80)
                                .padding([.leading, .trailing, .top, .bottom], 8)
                                .background(Color.gray.opacity(0.08))
                                .cornerRadius(12)
                        }

                        CardBottomSimpleDescriptionView(descriptionText: Text("Read more"), colorProvider: colorProvider, showChevron: true)

                }
                .frame(width: geometry.size.width)
                .background(viewHeightReader($totalHeight))
            }
        }
        .frame(height: totalHeight) // - variant for ScrollView/List
            //.frame(maxHeight: totalHeight) - variant for VStack
        }
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
        switch self.errorType {
        case .emptyData(type: _),
                .brokenData(type: _),
                .restrictedData(type: _):
            return "Data empty or restricted"
        case .advice(type: _, let imageSystemName):
            return "Advice"
        }
    }

    private func getImageSystemName() -> String? {
        switch self.errorType {
        case .emptyData(type: _),
                .brokenData(type: _),
                .restrictedData(type: _):
            return ""
        case .advice(type: _, let imageSystemName):
            return imageSystemName
        }
    }
    
    private func getDataText() -> String {
        switch self.errorType {
        case .emptyData(type: let type):
            return "No data of type \(type.rawValue) was recieved"
        case .brokenData(type: let type):
            return "There was not enought data to display your \(type.rawValue) charts. Try to sleep with Apple Watch More"
        case .restrictedData(type: let type):
            return "Sleepy was restricted from reading your \(type.rawValue) data. Fix that in your settings"
        case .advice(type: let type, _):
            switch type {
            case .wearMore:
                return "Try to sleep with your watch on your wrist to get phase, heart, and energy analysis"
            case .soundRecording:
                return "Record your sleep sounds by pressing ‘record’ button below  and get sound-recognision after you end recording"
            case .some:
                return ""
            }
        }
    }
    
    private func getIconName() -> String {
        switch self.errorType {
        case .emptyData(type: _), .brokenData(type: _):
            return "exclamationmark.square.fill"
        case .restrictedData(type: _):
            return "eye.slash.fill"
        case .advice(type: _):
            return "questionmark.square.dashed"
        }
    }
    
}

public struct ErrorView_Previews: PreviewProvider {
    public static var previews: some View {
        ErrorView(errorType: .brokenData(type: .heart),
                  colorProvider: ColorSchemeProvider())
    }
}
