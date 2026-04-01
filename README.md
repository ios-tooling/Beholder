# Beholder

A Swift framework for `@MainActor` observable instance state. Define typed key-value pairs on a central `Beholder` singleton and access them from SwiftUI views with automatic observation, or from anywhere via static accessors.

**Platforms:** iOS 17+ / macOS 14+
**Swift:** 6.3 (uses Swift Macros, `@Observable`)
**Dependencies:** [swift-syntax](https://github.com/swiftlang/swift-syntax)

## Architecture

```
Beholder (library)
  Beholder          @Observable @MainActor singleton, dictionary-backed [String: Any] storage
  BeholderKey<Kind> Sendable/Hashable key struct with a default value and unique name
  @BeholderValue    Accessor + Peer macro; generates instance + nonisolated static computed properties
  @Beholding        SwiftUI property wrapper; takes a WritableKeyPath<Beholder, Kind>, exposes Binding via $

BeholderMacros (compiler plugin)
  BeholderValueMacro   PeerMacro + AccessorMacro implementation using SwiftSyntax
```

## Defining Keys

Add a `@BeholderValue` property with a default value in a `Beholder` extension. The macro generates:

1. An **instance computed property** (accessor) using `BeholderKey` under the hood
2. A **`nonisolated static` computed property** forwarding through `instance`

```swift
public extension Beholder {
    @BeholderValue var isReady = false
    @BeholderValue var currentUser = ""
    @BeholderValue var retryCount: Int = 0  // explicit type annotation also supported
}
```

The type is inferred from the default value for `Bool`, `Int`, `Double`, and `String` literals. For other types, add an explicit type annotation.

## Usage

### SwiftUI views -- `@Beholding` property wrapper

```swift
struct SampleView: View {
    @Beholding(\.isReady) var isReady

    var body: some View {
        Text(isReady ? "Ready" : "Loading")
        Button("Toggle") { isReady.toggle() }
        Toggle("Ready", isOn: $isReady) // projected Binding
    }
}
```

### Static access from anywhere (nonisolated)

```swift
Beholder.isReady = true
let value = Beholder.isReady

// Works from detached tasks:
Task.detached {
    Beholder.isReady.toggle()
}
```

### Subscript access with `BeholderKey`

```swift
let key = BeholderKey<Bool>(false, "isReady")
Beholder.instance[key] = true
let value = Beholder[key]
```

## Observation

`Beholder` is `@Observable`. The underlying `values` dictionary is `@ObservationIgnored` with manual `access(keyPath:)` / `withMutation(keyPath:)` calls in the subscript, so SwiftUI views that read any key through the subscript chain will re-evaluate when any key changes.

All storage access (`instance`, `values`, subscript) is `nonisolated` to allow cross-isolation use. Thread safety is the caller's responsibility.

## Macro Details

`@BeholderValue` is both an `AccessorMacro` and a `PeerMacro`. Given:

```swift
@BeholderValue var isReady = false
```

It expands to:

```swift
var isReady {
    get { self[BeholderKey<Bool>(false, "isReady")] }
    set { self[BeholderKey<Bool>(false, "isReady")] = newValue }
}

nonisolated static var isReady: Bool {
    get { instance[BeholderKey<Bool>(false, "isReady")] }
    set { instance[BeholderKey<Bool>(false, "isReady")] = newValue }
}
```

Type inference from literals: `Bool`, `Int`, `Double`, `String`. For other types, use an explicit annotation: `@BeholderValue var items: [String] = []`.

Diagnostics are emitted when:
- Applied to a non-variable declaration
- No default value is provided
- The type cannot be inferred and no type annotation is present

## Package Integration

```swift
dependencies: [
    .package(url: "https://github.com/ios-tooling/Beholder.git", from: "1.0.0"),
],
targets: [
    .target(name: "MyApp", dependencies: ["Beholder"]),
]
```

## File Overview

| File | Purpose |
|------|---------|
| `Sources/Beholder/Beholder.swift` | `@Observable @MainActor` singleton with dictionary storage and subscripts |
| `Sources/Beholder/BeholderKey.swift` | Generic key struct (`Sendable`, `Hashable`, keyed by `name`) |
| `Sources/Beholder/Beholding.swift` | `@propertyWrapper` for SwiftUI views, provides `wrappedValue` + `Binding` |
| `Sources/Beholder/BeholderValueMacro.swift` | `#externalMacro` declaration |
| `Sources/Beholder/SampleView.swift` | Example key definition and SwiftUI usage |
| `Sources/BeholderMacros/BeholderValueMacro.swift` | `AccessorMacro` + `PeerMacro` implementation (SwiftSyntax) |
| `Sources/BeholderMacros/BeholderMacrosPlugin.swift` | `@main CompilerPlugin` entry point |
| `Tests/BeholderTests/BeholderTests.swift` | Runtime tests (Swift Testing) |
| `Tests/BeholderMacroTests/BeholderValueMacroTests.swift` | Macro expansion tests (XCTest + SwiftSyntaxMacrosTestSupport) |
