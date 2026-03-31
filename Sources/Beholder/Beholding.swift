import SwiftUI

@propertyWrapper @MainActor public struct Beholding<Kind: Sendable> {
	private let keyPath: ReferenceWritableKeyPath<Beholder, Kind>

	public init(_ keyPath: ReferenceWritableKeyPath<Beholder, Kind>) {
		self.keyPath = keyPath
	}

	public var wrappedValue: Kind {
		get { Beholder.instance[keyPath: keyPath] }
		nonmutating set { Beholder.instance[keyPath: keyPath] = newValue }
	}

	public var projectedValue: Binding<Kind> {
		Binding(
			get: { Beholder.instance[keyPath: keyPath] },
			set: { Beholder.instance[keyPath: keyPath] = $0 }
		)
	}
}
