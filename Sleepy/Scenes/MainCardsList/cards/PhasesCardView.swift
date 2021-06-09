import SwiftUI
import XUI

struct PhasesCardView: View {

    var body: some View {
        HStack {
            Image(systemName: "rectangle")
            Text("Thats a phases card")
        }.background(Color.orange)

    }
}

struct PhasesCardView_Previews: PreviewProvider {
    static var previews: some View {
        HeartCardView()
    }
}
