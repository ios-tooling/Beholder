import SwiftSyntax
import SwiftSyntaxMacros

public struct BeholderValueMacro: AccessorMacro, PeerMacro {

	// MARK: - AccessorMacro — generates get/set on the instance var

	public static func expansion(
		of node: AttributeSyntax,
		providingAccessorsOf declaration: some DeclSyntaxProtocol,
		in context: some MacroExpansionContext
	) throws -> [AccessorDeclSyntax] {
		let info = try extractPropertyInfo(from: declaration)

		let getter: AccessorDeclSyntax = """
			get {
				_beholderAccess(keyPath: \\.\(raw: info.name))
				return self[BeholderKey<\(raw: info.type)>(\(raw: info.defaultValue), "\(raw: info.name)")]
			}
			"""

		let setter: AccessorDeclSyntax = """
			set {
				_beholderMutation(keyPath: \\.\(raw: info.name)) {
					self[BeholderKey<\(raw: info.type)>(\(raw: info.defaultValue), "\(raw: info.name)")] = newValue
				}
			}
			"""

		return [getter, setter]
	}

	// MARK: - PeerMacro — generates a nonisolated static var forwarding to instance

	public static func expansion(
		of node: AttributeSyntax,
		providingPeersOf declaration: some DeclSyntaxProtocol,
		in context: some MacroExpansionContext
	) throws -> [DeclSyntax] {
		let info = try extractPropertyInfo(from: declaration)

		let staticProperty: DeclSyntax = """
			nonisolated static var \(raw: info.name): \(raw: info.type) {
				get {
					instance._beholderAccess(keyPath: \\.\(raw: info.name))
					return instance[BeholderKey<\(raw: info.type)>(\(raw: info.defaultValue), "\(raw: info.name)")]
				}
				set {
					instance._beholderMutation(keyPath: \\.\(raw: info.name)) {
						instance[BeholderKey<\(raw: info.type)>(\(raw: info.defaultValue), "\(raw: info.name)")] = newValue
					}
				}
			}
			"""

		return [staticProperty]
	}

	// MARK: - Helpers

	private static func extractPropertyInfo(
		from declaration: some DeclSyntaxProtocol
	) throws -> (name: String, type: String, defaultValue: String) {
		guard let varDecl = declaration.as(VariableDeclSyntax.self) else {
			throw BeholderMacroError.notAVariable
		}

		guard let binding = varDecl.bindings.first,
				let identPattern = binding.pattern.as(IdentifierPatternSyntax.self) else {
			throw BeholderMacroError.noBinding
		}

		guard let initializer = binding.initializer else {
			throw BeholderMacroError.missingDefault
		}

		let defaultValue = initializer.value.trimmedDescription
		let name = identPattern.identifier.text

		// Prefer explicit type annotation, fall back to inference from literal
		if let typeAnnotation = binding.typeAnnotation {
			return (name, typeAnnotation.type.trimmedDescription, defaultValue)
		}

		if let inferredType = inferType(from: initializer.value) {
			return (name, inferredType, defaultValue)
		}

		throw BeholderMacroError.cannotInferType
	}

	private static func inferType(from expr: ExprSyntax) -> String? {
		if expr.is(BooleanLiteralExprSyntax.self) { return "Bool" }
		if expr.is(IntegerLiteralExprSyntax.self) { return "Int" }
		if expr.is(FloatLiteralExprSyntax.self) { return "Double" }
		if expr.is(StringLiteralExprSyntax.self) { return "String" }
		return nil
	}
}

enum BeholderMacroError: Error, CustomStringConvertible {
	case notAVariable
	case noBinding
	case missingDefault
	case cannotInferType

	var description: String {
		switch self {
		case .notAVariable: "@BeholderValue can only be applied to variable declarations"
		case .noBinding: "@BeholderValue requires a property binding"
		case .missingDefault: "@BeholderValue requires a default value (e.g. @BeholderValue var isReady = false)"
		case .cannotInferType: "@BeholderValue could not infer the type. Add an explicit type annotation (e.g. var name: String = \"\")"
		}
	}
}
