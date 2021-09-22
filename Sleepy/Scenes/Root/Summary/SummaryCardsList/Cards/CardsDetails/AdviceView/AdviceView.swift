//
//  AdviceView.swift
//  Sleepy
//
//  Created by Анас Бен Мустафа on 9/22/21.
//

import SwiftUI

enum AdviceType {
    case sleepImportance
    case sleepImprovement
    case phasesAdvice
    case heartAdvice
}

struct AdviceView: View {

    private let sheetType: AdviceType

    init(sheetType: AdviceType) {
        self.sheetType = sheetType
    }

    var body: some View {
        VStack {

        }
    }
}

// MARK: Configuration functions

