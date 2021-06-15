//
//  AlarmCoordinatorView.swift
//  Sleepy
//
//  Created by Анас Бен Мустафа on 6/14/21.
//

import Foundation
import SwiftUI
import XUI

struct AlarmCoordinatorView: View {
    
    // MARK: Stored Properties
    
    @Store var coordinator: AlarmCoordinator
    
    // MARK: Views
    
    var body: some View {
        Text("This is alarm view")
    }
    
}
