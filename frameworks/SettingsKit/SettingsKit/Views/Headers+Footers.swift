// Copyright (c) 2022 Sleepy.

import SwiftUI

public struct HeaderView: View {
    private var imageName: String?
    private var text: String

    public init(text: String, imageName: String? = nil) {
        self.imageName = imageName
        self.text = text
    }

    public var body: some View {
        HStack {
            if let imageName = imageName {
                Image(systemName: imageName)
            }
            Text(text)
        }
    }
}
