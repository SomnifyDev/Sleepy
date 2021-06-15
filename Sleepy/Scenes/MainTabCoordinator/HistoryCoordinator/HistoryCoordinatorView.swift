//
//  HistoryCoordinatorView.swift
//  Sleepy
//
//  Created by Анас Бен Мустафа on 6/14/21.
//

import Foundation
import SwiftUI
import XUI

struct HistoryCoordinatorView: View {
    
    // MARK: Stored Properties
    
    @Store var coordinator: HistoryCoordinator
    
    // MARK: Views
    
    var body: some View {
        Text("This is history view")
    }
    
}
