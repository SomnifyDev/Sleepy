//
//  Views.swift
//  SettingsKit
//
//  Created by Анас Бен Мустафа on 8/5/21.
//

import SwiftUI

public struct HFView: View {

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
