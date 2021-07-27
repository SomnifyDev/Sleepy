import SwiftUI

public struct UsefulInfoCardView: View {

    @State private var totalHeight = CGFloat.zero
    private let imageName: String
    private let title: String
    private let description: String

    public init(imageName: String, title: String, description: String) {
        self.imageName = imageName
        self.title = title
        self.description = description
    }

    public var body: some View {
        VStack {
            GeometryReader { geometry in
                VStack {
                    Image(imageName)
                        .resizable()
                        .frame(width: geometry.size.width, height: 235)

                    VStack (spacing: 16) {
                        HStack {
                            Text(title)
                                .fontWeight(.bold)
                                .font(.title2)
                            Spacer()
                        }

                        HStack {
                            Text(description)
                                .font(.none)
                            Spacer()
                        }
                    }
                    .padding()

                    Spacer()
                }
                .background(viewHeightReader($totalHeight))
                .cornerRadius(10)
            }
        }
        .frame(height: totalHeight)
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

struct UsefulInfoCardView_Previews: PreviewProvider {
    static var previews: some View {
        UsefulInfoCardView(imageName: "heart1", title: "title", description: "decription")
    }
}
