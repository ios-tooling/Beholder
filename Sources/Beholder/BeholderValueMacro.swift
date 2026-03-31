@attached(accessor)
@attached(peer, names: arbitrary)
public macro BeholderValue<T>(default: T) = #externalMacro(module: "BeholderMacros", type: "BeholderValueMacro")
