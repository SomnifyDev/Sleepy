// Copyright (c) 2021 Sleepy.

import SwiftUI

extension Binding {
	func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
		Binding(
			get: { self.wrappedValue },
			set: { newValue in
				self.wrappedValue = newValue
				handler(newValue)
			}
		)
	}
}
