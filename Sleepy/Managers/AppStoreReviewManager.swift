//
//  AppStoreReviewManager.swift
//  Sleepy
//
//  Created by Никита Казанцев on 08.08.2021.
// https://www.raywenderlich.com/9009-requesting-app-ratings-and-reviews-tutorial-for-ios

import Foundation
import StoreKit

enum AppStoreReviewManager {
    static let minimumReviewWorthyActionCount = 3

    static func requestReviewIfAppropriate() {
        let defaults = UserDefaults.standard
        let bundle = Bundle.main

        var actionCount = defaults.integer(forKey: .reviewWorthyActionCount)
        actionCount += 1
        defaults.set(actionCount, forKey: .reviewWorthyActionCount)

        guard actionCount >= minimumReviewWorthyActionCount else {
            return
        }

        let bundleVersionKey = kCFBundleVersionKey as String
        let currentVersion = bundle.object(forInfoDictionaryKey: bundleVersionKey) as? String
        let lastVersion = defaults.string(forKey: .lastReviewRequestAppVersion)

        guard lastVersion == nil || lastVersion != currentVersion else {
            return
        }

        if #available(iOS 14.0, *) {
            if let scene = UIApplication.shared.windows.first?.windowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        } else {
            SKStoreReviewController.requestReview()
        }

        defaults.set(0, forKey: .reviewWorthyActionCount)
        defaults.set(currentVersion, forKey: .lastReviewRequestAppVersion)
    }
}
