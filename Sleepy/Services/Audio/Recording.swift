//
//  Recording.swift
//  Sleepy
//
//  Created by Никита Казанцев on 14.08.2021.
//

import Foundation

struct Recording: Hashable, Identifiable {
    let id = UUID()
    let fileURL: URL
    let createdAt: Date

    static func < (lhs: Recording, rhs: Recording) -> Bool {
        return lhs.createdAt < rhs.createdAt
    }
}
