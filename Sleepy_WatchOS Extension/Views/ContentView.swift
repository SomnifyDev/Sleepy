import SwiftUI

struct ContentView: View {
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack (spacing: 8) {
                    NavigationLink(destination: AlarmView()) {
                        NavItemView(
                            imageName: "alarm",
                            title: "Smart alarm",
                            titleColor: Color("mainColor"),
                            mainInfo: "8:30",
                            bottomTitle: "Active"
                        )                                                    .frame(height: 84)
                            .background(Color.white.opacity(0.15))
                            .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .navigationTitle("Sleepy")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
