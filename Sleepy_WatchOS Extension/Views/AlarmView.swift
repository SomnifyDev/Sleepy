//
//  AlarmView.swift
//  Sleepy_WatchOS Extension
//
//  Created by Анас Бен Мустафа on 9/27/21.
//

import SwiftUI

struct AlarmView: View {
    @State private var selectedHour = Date().getHourInt()
    @State private var selectedMinute = Date().getMinuteInt()

    @State private var isActive = false

    let hours = [Int](0...23)
    let minutes = [Int](0...59)

    var body: some View {
        VStack {
            HStack {
                Picker("Hours", selection: $selectedHour) {
                    ForEach(hours, id: \.self) {
                        Text(String($0))
                    }
                }

                Picker("Minutes", selection: $selectedMinute) {
                    ForEach(minutes, id: \.self) {
                        Text(String($0))
                    }
                }
            }
            .padding(.top, 16)
            .frame(height: 70, alignment: .center)

            Spacer()

            Button(
                action: doJob, label: {
                    Text(isActive ? "Cancel" : "Set up")
                })

        }
    }

    let doJob = {

    }
}

struct AlarmView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmView()
    }
}

extension Date {
    func getHourInt() -> Int {
        let df = DateFormatter()
        df.setLocalizedDateFormatFromTemplate("HH")
        return Int(df.string(from: self))!
    }

    func getMinuteInt() -> Int {
        let df = DateFormatter()
        df.setLocalizedDateFormatFromTemplate("mm")
        return Int(df.string(from: self))!
    }
}
