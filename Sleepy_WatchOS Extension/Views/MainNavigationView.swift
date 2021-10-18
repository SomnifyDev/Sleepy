import SwiftUI

struct MainNavigationView: View {

    @State var mainInfo: String = "-"
    @State var bottomTitle: String = "Inactive".localized

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack (spacing: 8) {
                    NavigationLink(destination: AlarmView()) {
                        NavItemView(
                            imageName: "alarm",
                            title: "Smart alarm".localized,
                            titleColor: Color("mainColor"),
                            mainInfo: mainInfo,
                            bottomTitle: bottomTitle
                        )
                            .frame(height: 84)
                            .background(
                                Color.white.opacity(0.15)
                            )
                            .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .navigationTitle("Sleepy")
            }
            .onAppear {
                setUpView()
            }
        }
    }

    private func setUpView() {
        guard
            UserSettings.isAlarmSet,
            UserSettings.settedAlarmHours != -1,
            UserSettings.settedAlarmMinutes != -1
        else {
            mainInfo = "-"
            bottomTitle = "Inactive"
            return
        }

        mainInfo = "\(UserSettings.settedAlarmHours):\(UserSettings.settedAlarmMinutes)"
        bottomTitle = "Active".localized
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainNavigationView()
    }
}
