//
//  RecipeView.swift
//  Recipes
//
//  Created by Paul Kraft on 11.12.20.
//

import SwiftUI
import XUI

struct CardView: View {

    // MARK: Stored Properties

    @Store var viewModel: CardViewModel

    // MARK: Views

    var body: some View {
        HStack {
            Text(viewModel.card.title)
        }
    }

}
