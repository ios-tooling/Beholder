import Observation
import os

@Observable
@MainActor public class Beholder {
	nonisolated public static let instance = Beholder()

	@ObservationIgnored nonisolated(unsafe) private var values: [String: Any] = [:]
	@ObservationIgnored private nonisolated let lock = OSAllocatedUnfairLock()

	nonisolated public init() {}

	nonisolated public subscript<Kind>(key: BeholderKey<Kind>) -> Kind {
		get {
			access(keyPath: \.values)
			return lock.withLock { values[key.name] as? Kind ?? key.defaultValue }
		}

		set {
			withMutation(keyPath: \.values) {
				lock.withLock { values[key.name] = newValue }
			}
		}
	}

	nonisolated public static subscript<Kind>(key: BeholderKey<Kind>) -> Kind {
		get { instance[key] }
		set { instance[key] = newValue }
	}
}
