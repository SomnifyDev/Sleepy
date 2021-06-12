import SwiftUI
import XUI

struct HeartCardView: View {

    var body: some View {
        HStack {
            Image(systemName: "person")
            Text("Thats a heart card")
        }.background(Color.pink)

    }
}

struct HeartCardView_Previews: PreviewProvider {
    static var previews: some View {
        HeartCardView()
    }
}
