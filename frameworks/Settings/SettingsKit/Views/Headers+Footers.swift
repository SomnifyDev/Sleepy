//
//  Views.swift
//  SettingsKit
//
//  Created by Анас Бен Мустафа on 8/5/21.
//

import SwiftUI

public struct HFWithImageView: View {

    private var imageName: String
    private var text: String

    public init(imageName: String, text: String) {
        self.imageName = imageName
        self.text = text
    }

    public var body: some View {
        HStack {
            Image(systemName: imageName)
            Text(text)
        }
    }

}

public struct HFView: View {

    private var text: String

    public init( text: String) {
        self.text = text
    }

    public var body: some View {
        Text(text)
    }

}
