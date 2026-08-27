# swift-xcode

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Xcode workspace and shared-scheme serialization with atomic file generation, without importing Foundation.

---

## Quick Start

```swift
import Xcode_Workspace

let workspace = Xcode.Workspace(references: [
    .init(location: .group("Application")),
    .init(location: .group("Packages/swift-json"))
])

try workspace.write(to: "/path/to/institute.xcworkspace")
```

Serialization flows through the Layer-4 [swift-xml](https://github.com/swift-compositions/swift-xml) package; application consumers do not serialize W3C XML directly.

---

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/swift-compositions/swift-xcode.git", branch: "main")
]
```

Add a product to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "Xcode Workspace", package: "swift-xcode")
    ]
)
```

Products:

- `Xcode Workspace` exposes `Xcode.Workspace` serialization and atomic writes.
- `Xcode Scheme` exposes `Xcode.Scheme` serialization and atomic writes.

### Requirements

- Swift 6.3+
- macOS 26+

---

## Error Handling

Workspace and scheme writes throw a typed `Error` with the same three cases on
each product (`Xcode.Workspace.Error`, `Xcode.Scheme.Error`):

```
Xcode.Workspace.Error / Xcode.Scheme.Error
├── .path      // the destination path is invalid
├── .create    // the container could not be created
└── .write     // serialization could not be written atomically
```

```swift
do {
    try workspace.write(to: "/path/to/institute.xcworkspace")
} catch .path {
    // invalid destination path
} catch .create {
    // could not create the .xcworkspace container
} catch .write {
    // atomic write failed
}
```

---

## Community

<!-- BEGIN: discussion -->
*Discussion thread will be created at the first public release.*
<!-- END: discussion -->

---

## License

Apache 2.0. See [LICENSE](LICENSE.md).
