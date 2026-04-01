import Observation

@Observable
@MainActor public class Beholder {
	nonisolated public static let instance = Beholder()

	@ObservationIgnored nonisolated(unsafe) var values: [String: Any] = [:]

	nonisolated public init() {}

	nonisolated public subscript<Kind>(key: BeholderKey<Kind>) -> Kind {
		get {
			access(keyPath: \.values)
			return values[key.name] as? Kind ?? key.defaultValue
		}

		set {
			withMutation(keyPath: \.values) {
				values[key.name] = newValue
			}
		}
	}

	nonisolated public static subscript<Kind>(key: BeholderKey<Kind>) -> Kind {
		get { instance[key] }
		set { instance[key] = newValue }
	}
}
