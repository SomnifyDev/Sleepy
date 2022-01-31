// Copyright (c) 2022 Sleepy.

import SwiftUI

struct NeedHealthAccessView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    Image(systemName: "applewatch.side.right")
                        .foregroundColor(.blue)
                        .opacity(0.85)
                        .font(.system(size: 25))
                    Image(systemName: "waveform.path.ecg")
                        .foregroundColor(.red)
                        .opacity(0.75)
                        .font(.system(size: 25))
                    Image(systemName: "figure.walk")
                        .foregroundColor(.orange)
                        .font(.system(size: 25))
                }
                .padding(.top, 8)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Sleepy requires an access for your health data to make smart alarm usable.")
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.system(size: 12))
                    Text("Also make sure you have turned on heart and energy tracking on your Apple Watch.")
                        .font(.system(size: 12))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

struct NeedHealthAccessView_Previews: PreviewProvider {
    static var previews: some View {
        NeedHealthAccessView()
    }
}
