// Copyright (c) 2022 Sleepy.

import Foundation

struct Recording: Hashable, Identifiable {
    let id = UUID()
    let fileURL: URL
    let createdAt: Date

    static func < (lhs: Recording, rhs: Recording) -> Bool {
        return lhs.createdAt < rhs.createdAt
    }
}
