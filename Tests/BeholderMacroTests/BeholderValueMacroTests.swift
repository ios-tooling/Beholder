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

				static var isSyncing: Bool {
					get {
					    shared.isSyncing
					}
					set {
					    shared.isSyncing = newValue
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

				static var userName: String {
					get {
					    shared.userName
					}
					set {
					    shared.userName = newValue
					}
				}
			}
			""",
			macros: macros
		)
	}

	func testMissingDefaultDiagnostic() throws {
		assertMacroExpansion(
			"""
			extension Beholder {
				@BeholderValue
				var isSyncing: Bool
			}
			""",
			expandedSource: """
			extension Beholder {
				var isSyncing: Bool

				static var isSyncing: Bool {
					get {
					    shared.isSyncing
					}
					set {
					    shared.isSyncing = newValue
					}
				}
			}
			""",
			diagnostics: [
				DiagnosticSpec(message: "@BeholderValue requires a default value (e.g. @BeholderValue(default: false))", line: 2, column: 2),
			],
			macros: macros
		)
	}
}
