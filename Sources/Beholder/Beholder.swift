import Observation

@Observable
@MainActor public class Beholder {
	public static let shared = Beholder()

	var values: [String: Any] = [:]

	public init() {}

	subscript<Kind>(key: BeholderKey<Kind>) -> Kind {
		get {
			values[key.name] as? Kind ?? key.defaultValue
		}

		set {
			values[key.name] = newValue
		}
	}

	public static subscript<Kind>(key: BeholderKey<Kind>) -> Kind {
		get { shared[key] }
		set { shared[key] = newValue }
	}
}
