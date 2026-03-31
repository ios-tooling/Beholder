import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct BeholderMacrosPlugin: CompilerPlugin {
	let providingMacros: [Macro.Type] = [
		BeholderValueMacro.self,
	]
}
