import SwiftSyntax
import SwiftSyntaxMacros

public struct BeholderValueMacro: AccessorMacro, PeerMacro {

	// MARK: - AccessorMacro — generates get/set on the instance var

	public static func expansion(
		of node: AttributeSyntax,
		providingAccessorsOf declaration: some DeclSyntaxProtocol,
		in context: some MacroExpansionContext
	) throws -> [AccessorDeclSyntax] {
		let (propertyName, kindType) = try extractPropertyInfo(from: declaration)
		let defaultValue = try extractDefaultValue(from: node)

		let getter: AccessorDeclSyntax = """
			get {
				self[BeholderKey<\(raw: kindType)>(\(raw: defaultValue), "\(raw: propertyName)")]
			}
			"""

		let setter: AccessorDeclSyntax = """
			set {
				self[BeholderKey<\(raw: kindType)>(\(raw: defaultValue), "\(raw: propertyName)")] = newValue
			}
			"""

		return [getter, setter]
	}

	// MARK: - PeerMacro — generates a static var forwarding to instance

	public static func expansion(
		of node: AttributeSyntax,
		providingPeersOf declaration: some DeclSyntaxProtocol,
		in context: some MacroExpansionContext
	) throws -> [DeclSyntax] {
		let (propertyName, kindType) = try extractPropertyInfo(from: declaration)
		let defaultValue = try extractDefaultValue(from: node)

		let staticProperty: DeclSyntax = """
			nonisolated static var \(raw: propertyName): \(raw: kindType) {
				get { instance[BeholderKey<\(raw: kindType)>(\(raw: defaultValue), "\(raw: propertyName)")] }
				set { instance[BeholderKey<\(raw: kindType)>(\(raw: defaultValue), "\(raw: propertyName)")] = newValue }
			}
			"""

		return [staticProperty]
	}

	// MARK: - Helpers

	private static func extractPropertyInfo(
		from declaration: some DeclSyntaxProtocol
	) throws -> (name: String, type: String) {
		guard let varDecl = declaration.as(VariableDeclSyntax.self) else {
			throw BeholderMacroError.notAVariable
		}

		guard let binding = varDecl.bindings.first,
				let identPattern = binding.pattern.as(IdentifierPatternSyntax.self) else {
			throw BeholderMacroError.noBinding
		}

		guard let typeAnnotation = binding.typeAnnotation else {
			throw BeholderMacroError.missingTypeAnnotation
		}

		return (identPattern.identifier.text, typeAnnotation.type.trimmedDescription)
	}

	private static func extractDefaultValue(from node: AttributeSyntax) throws -> String {
		guard let arguments = node.arguments?.as(LabeledExprListSyntax.self),
				let firstArg = arguments.first,
				firstArg.label?.text == "default" else {
			throw BeholderMacroError.missingDefault
		}

		return firstArg.expression.trimmedDescription
	}
}

enum BeholderMacroError: Error, CustomStringConvertible {
	case notAVariable
	case noBinding
	case missingTypeAnnotation
	case missingDefault

	var description: String {
		switch self {
		case .notAVariable: "@BeholderValue can only be applied to variable declarations"
		case .noBinding: "@BeholderValue requires a property binding"
		case .missingTypeAnnotation: "@BeholderValue requires an explicit type annotation (e.g. var isSyncing: Bool)"
		case .missingDefault: "@BeholderValue requires a default value (e.g. @BeholderValue(default: false))"
		}
	}
}
