import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
@testable import BeholderMacros

final class BeholderValueMacroTests: XCTestCase {
	let macros: [String: Macro.Type] = [
		"BeholderValue": BeholderValueMacro.self,
	]

	func testBoolExpansion() throws {
		assertMacroExpansion(
			"""
			extension Beholder {
				@BeholderValue var isSyncing = false
			}
			""",
			expandedSource: """
			extension Beholder {
				var isSyncing {
				    get {
				    	_beholderAccess(keyPath: \\.isSyncing)
				    	return self[BeholderKey<Bool>(false, "isSyncing")]
				    }
				    set {
				    	_beholderMutation(keyPath: \\.isSyncing) {
				    		self[BeholderKey<Bool>(false, "isSyncing")] = newValue
				    	}
				    }
				}

				nonisolated static var isSyncing: Bool {
					get {
						instance._beholderAccess(keyPath: \\.isSyncing)
						return instance[BeholderKey<Bool>(false, "isSyncing")]
					}
					set {
						instance._beholderMutation(keyPath: \\.isSyncing) {
							instance[BeholderKey<Bool>(false, "isSyncing")] = newValue
						}
					}
				}
			}
			""",
			macros: macros
		)
	}

	func testStringExpansion() throws {
		assertMacroExpansion(
			"""
			extension Beholder {
				@BeholderValue var userName = ""
			}
			""",
			expandedSource: """
			extension Beholder {
				var userName {
				    get {
				    	_beholderAccess(keyPath: \\.userName)
				    	return self[BeholderKey<String>("", "userName")]
				    }
				    set {
				    	_beholderMutation(keyPath: \\.userName) {
				    		self[BeholderKey<String>("", "userName")] = newValue
				    	}
				    }
				}

				nonisolated static var userName: String {
					get {
						instance._beholderAccess(keyPath: \\.userName)
						return instance[BeholderKey<String>("", "userName")]
					}
					set {
						instance._beholderMutation(keyPath: \\.userName) {
							instance[BeholderKey<String>("", "userName")] = newValue
						}
					}
				}
			}
			""",
			macros: macros
		)
	}

	func testExplicitTypeAnnotation() throws {
		assertMacroExpansion(
			"""
			extension Beholder {
				@BeholderValue var count: Int = 0
			}
			""",
			expandedSource: """
			extension Beholder {
				var count: Int {
				    get {
				    	_beholderAccess(keyPath: \\.count)
				    	return self[BeholderKey<Int>(0, "count")]
				    }
				    set {
				    	_beholderMutation(keyPath: \\.count) {
				    		self[BeholderKey<Int>(0, "count")] = newValue
				    	}
				    }
				}

				nonisolated static var count: Int {
					get {
						instance._beholderAccess(keyPath: \\.count)
						return instance[BeholderKey<Int>(0, "count")]
					}
					set {
						instance._beholderMutation(keyPath: \\.count) {
							instance[BeholderKey<Int>(0, "count")] = newValue
						}
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
				@BeholderValue var isReady: Bool
			}
			""",
			expandedSource: """
			extension Beholder {
				var isReady: Bool
			}
			""",
			diagnostics: [
				DiagnosticSpec(message: #"@BeholderValue requires a default value (e.g. @BeholderValue var isReady = false)"#, line: 2, column: 2),
				DiagnosticSpec(message: #"@BeholderValue requires a default value (e.g. @BeholderValue var isReady = false)"#, line: 2, column: 2),
			],
			macros: macros
		)
	}
}
