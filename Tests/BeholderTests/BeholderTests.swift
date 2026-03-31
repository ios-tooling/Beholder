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
}
