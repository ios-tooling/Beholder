# Beholder

Observable singleton for shared app state. Replaces custom `@Observable` singleton classes (like `SyncEngineUI`, `DataStoreUI`) with centralized, type-safe key-value storage.

## Defining properties

Use `@BeholderValue` with an initializer in a `public extension Beholder`:

```swift
public extension Beholder {
    @BeholderValue var isReady = false
    @BeholderValue var syncPhase: SyncPhase = .idle
    @BeholderValue var progress: Double? = nil
}
```

- No `default:` label — just use `= value`
- Type is inferred for `Bool`, `Int`, `Double`, `String` literals
- For all other types (enums, optionals, arrays, etc.), add an explicit type annotation

## Reading in SwiftUI views

Use `@Beholding` with a key path:

```swift
struct MyView: View {
    @Beholding(\.isReady) var isReady

    var body: some View {
        Toggle("Ready", isOn: $isReady)
    }
}
```

Or observe via the instance directly:

```swift
var beholder = Beholder.instance
// then use beholder.isReady in body — observation tracking works automatically
```

## Writing from anywhere

```swift
Beholder.isReady = true
Beholder.syncPhase = .downloading
```

Static access is `nonisolated`, safe from detached tasks.

## Key rules

- Always define properties in `public extension Beholder { }` blocks
- One `@BeholderValue` per property — the macro generates both instance and `nonisolated static` accessors
- Do not write manual getters/setters — the macro handles everything
