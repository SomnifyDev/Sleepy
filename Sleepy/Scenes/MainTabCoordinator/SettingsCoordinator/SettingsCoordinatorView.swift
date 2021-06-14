//
//  SettingsCoordinatorView.swift
//  Sleepy
//
//  Created by Анас Бен Мустафа on 6/14/21.
//

import Foundation
import SwiftUI
import XUI

struct SettingsCoordinatorView: View {
    
    // MARK: Stored Properties
    
    @Store var coordinator: SettingsCoordinator
    
    // MARK: Views
    
    var body: some View {
        Text("This is settings view")
    }
    
}
