import Testing
@testable import Beholder

@MainActor
@Suite struct BeholderTests {
	@Test func defaultValue() {
		let beholder = Beholder()
		#expect(beholder.isReady == false)
	}

	@Test func setValue() {
		let beholder = Beholder()
		beholder.isReady = true
		#expect(beholder.isReady == true)
	}

	@Test func staticAccess() {
		Beholder.isReady = false
		#expect(Beholder.isReady == false)
		Beholder.isReady = true
		#expect(Beholder.isReady == true)
	}

	@Test func subscriptAccess() {
		let beholder = Beholder()
		let key = BeholderKey<Bool>(false, "isReady")
		#expect(beholder[key] == false)
		beholder[key] = true
		#expect(beholder[key] == true)
	}

	@Test func concurrentAccess() async {
		let key = BeholderKey<Int>(0, "counter")
		let iterations = 1000

		await withTaskGroup(of: Void.self) { group in
			for i in 0..<iterations {
				group.addTask {
					Beholder.instance[key] = i
					_ = Beholder.instance[key]
				}
			}
		}

		let value = Beholder.instance[key]
		#expect(value >= 0 && value < iterations)
	}
}
