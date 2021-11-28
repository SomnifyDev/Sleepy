// Copyright (c) 2021 Sleepy.

import SwiftUI

struct MainNavigationView: View {
    @State var mainInfo: String = "-"
    @State var bottomTitle: String = "Inactive"

    var body: some View {
        GeometryReader { _ in
            ScrollView {
                VStack(spacing: 8) {
                    NavigationLink(destination: AlarmView()) {
                        NavItemView(
                            imageName: "alarm",
                            title: "Smart alarm",
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

    // MARK: Private methods

    private func integerToString(_ integer: Int) -> String {
        let minutesStr = integer > 9 ? String(integer) : "0" + String(integer)
        return minutesStr
    }

    private func setUpView() {
        guard
            UserSettings.isAlarmSet,
            UserSettings.settedAlarmHours != -1,
            UserSettings.settedAlarmMinutes != -1 else
        {
            self.mainInfo = "-"
            self.bottomTitle = "Inactive"
            return
        }

        self.mainInfo = "\(self.integerToString(UserSettings.settedAlarmHours)):\(self.integerToString(UserSettings.settedAlarmMinutes))"
        self.bottomTitle = "Active"
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainNavigationView()
    }
}
