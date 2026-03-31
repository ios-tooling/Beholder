import Testing
@testable import Beholder

@MainActor
@Suite struct BeholderTests {
	@Test func defaultValue() {
		let beholder = Beholder()
		#expect(beholder.isSyncing == false)
	}

	@Test func setValue() {
		let beholder = Beholder()
		beholder.isSyncing = true
		#expect(beholder.isSyncing == true)
	}

	@Test func staticAccess() {
		Beholder.isSyncing = false
		#expect(Beholder.isSyncing == false)
		Beholder.isSyncing = true
		#expect(Beholder.isSyncing == true)
	}
}
