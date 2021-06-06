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
    
    public var errorType: ErrorType
    
    var iconName: String = ""
    var titleText: String = ""
    var dataText: String = ""
    
    public init(errorType: ErrorType) {
        self.errorType = errorType
        
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
                        .foregroundColor(.blue)
                    Text("titleText")
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
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
            .background(Color.yellow)
        }
    }
    
    // MARK: Private Methods
    
    private func getTitleText() -> String {
        if errorType == .brokenData(type: .some) {
            // TODO: add switch for different data broken states
            return "data broken"
        } else {
            return "data empty"
        }
    }
    
    private func getDataText() -> String {
        if errorType == .brokenData(type: .some) {
            // TODO: add switch for different data broken states
            return "data broken"
        } else {
            return "data empty"
        }
    }
    
    private func getIconName() -> String {
        // TODO: add switch for different data states
        return "person"
    }
    
}

public struct ErrorView_Previews: PreviewProvider {
    public static var previews: some View {
        ErrorView(errorType: .brokenData(type: .heart))
    }
}
