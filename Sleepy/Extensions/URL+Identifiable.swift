// Copyright (c) 2021 Sleepy.

import Foundation

extension URL: Identifiable {
	public var id: String {
		absoluteString
	}
}
