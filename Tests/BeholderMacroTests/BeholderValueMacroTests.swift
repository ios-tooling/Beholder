import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
@testable import BeholderMacros

final class BeholderValueMacroTests: XCTestCase {
	let macros: [String: Macro.Type] = [
		"BeholderValue": BeholderValueMacro.self,
	]

	func testExpansion() throws {
		assertMacroExpansion(
			"""
			extension Beholder {
				@BeholderValue(default: false)
				var isSyncing: Bool
			}
			""",
			expandedSource: """
			extension Beholder {
				var isSyncing: Bool {
				    get {
				    	self[BeholderKey<Bool>(false, "isSyncing")]
				    }
				    set {
				    	self[BeholderKey<Bool>(false, "isSyncing")] = newValue
				    }
				}

				nonisolated static var isSyncing: Bool {
					get {
					    instance[BeholderKey<Bool>(false, "isSyncing")]
					}
					set {
					    instance[BeholderKey<Bool>(false, "isSyncing")] = newValue
					}
				}
			}
			""",
			macros: macros
		)
	}

	func testStringDefault() throws {
		assertMacroExpansion(
			"""
			extension Beholder {
				@BeholderValue(default: "")
				var userName: String
			}
			""",
			expandedSource: """
			extension Beholder {
				var userName: String {
				    get {
				    	self[BeholderKey<String>("", "userName")]
				    }
				    set {
				    	self[BeholderKey<String>("", "userName")] = newValue
				    }
				}

				nonisolated static var userName: String {
					get {
					    instance[BeholderKey<String>("", "userName")]
					}
					set {
					    instance[BeholderKey<String>("", "userName")] = newValue
					}
				}
			}
			""",
			macros: macros
		)
	}
}
