//
//  ColorSchemeProvider.swift
//  Sleepy
//
//  Created by Анас Бен Мустафа on 6/9/21.
//

import UIKit

public final class ColorSchemeProvider: ObservableObject {
    
    let sleepyColorScheme: colorManager
    
    public init() {
        self.sleepyColorScheme = colorManager()
    }
    
}
