import Foundation

public struct BeholderKey<Kind: Sendable>: Sendable, Hashable {
	public let defaultValue: Kind
	public var name: String

	public init(_ defaultValue: Kind, _ name: String? = nil) {
		self.defaultValue = defaultValue
		self.name = name ?? "\(#file) \(#function) \(#line)"
	}

	public func hash(into hasher: inout Hasher) {
		hasher.combine(name)
	}

	public static func ==(lhs: Self, rhs: Self) -> Bool {
		lhs.name == rhs.name
	}
}

// sample Beholder key:
// @Beholding(\.isSyncing) var isSyncing
// Beholder.isSyncing = true
