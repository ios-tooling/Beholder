@attached(accessor)
@attached(peer, names: arbitrary)
public macro BeholderValue() = #externalMacro(module: "BeholderMacros", type: "BeholderValueMacro")
