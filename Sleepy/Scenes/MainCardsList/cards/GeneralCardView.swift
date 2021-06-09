import SwiftUI
import XUI

struct GeneralCardView: View {

    var body: some View {
        HStack {
            Image(systemName: "swift")
            Text("Thats a general card")
        }.background(Color.blue)

    }
}

struct GeneralCardView_Previews: PreviewProvider {
    static var previews: some View {
        HeartCardView()
    }
}
