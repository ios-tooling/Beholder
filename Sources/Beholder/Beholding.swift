import SwiftUI

@propertyWrapper @MainActor public struct Beholding<Kind: Sendable> {
	private let keyPath: ReferenceWritableKeyPath<Beholder, Kind>

	public init(_ keyPath: ReferenceWritableKeyPath<Beholder, Kind>) {
		self.keyPath = keyPath
	}

	public var wrappedValue: Kind {
		get { Beholder.shared[keyPath: keyPath] }
		nonmutating set { Beholder.shared[keyPath: keyPath] = newValue }
	}

	public var projectedValue: Binding<Kind> {
		Binding(
			get: { Beholder.shared[keyPath: keyPath] },
			set: { Beholder.shared[keyPath: keyPath] = $0 }
		)
	}
}
