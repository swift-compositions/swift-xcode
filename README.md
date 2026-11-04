# swift-xcode

Use this package when a tool generates or reads Xcode workspaces, or writes shared schemes into one, without Foundation. Start from `Xcode.Workspace` with `Xcode.Workspace.write(to:)` and `Xcode.Workspace.read(from:)`, and from `Xcode.Scheme` with `Xcode.Scheme.write(_:to:)`. If you only need the workspace and scheme types, use swift-xcode-standard.

## Laws

- `Xcode.Workspace.write(to:)` takes the `.xcworkspace` directory, creates it and any missing parents, and replaces `contents.xcworkspacedata` atomically. `Xcode.Workspace.read(from:)` takes the same directory and fails when that file isn't there.
- The output is indented XML 1.0 with a UTF-8 declaration, and attribute values are XML-escaped, so `&` is written as `&amp;`. Parsing that output gives back an equal workspace. The bytes of a hand-edited file are not preserved.
- Parsing is strict. The root must be `Workspace` with only a non-empty `version` attribute. A `FileRef` must have only a `location` attribute and no children. A `Group` must have only `location` and a non-empty `name`. Any other element, or any extra or missing attribute, fails the parse.
- Parsing keeps the order and nesting of references. A location scheme the package doesn't know, such as `future:`, is kept rather than refused.
- `Xcode.Scheme.write(_:to:)` takes the workspace directory and a scheme name, creates `xcshareddata/xcschemes` inside it, and replaces the `.xcscheme` file of that name atomically.
- A scheme has no launch action, because xcodebuild crashes on a stub one. Testing and analysis use Debug, profiling and archiving use Release, and every build entry is built for testing, running, profiling, archiving and analysing. A test entry is parallelizable only when you say so.
