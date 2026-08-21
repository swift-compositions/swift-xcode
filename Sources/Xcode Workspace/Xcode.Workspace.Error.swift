public import Xcode_Workspace_Standard

extension Xcode.Workspace {
    public enum Error: Swift.Error, Sendable, Equatable {
        case path
        case create
        case write
        case read
        case invalidBundle
        case malformedXML
        case invalidRoot(Swift.String)
        case invalidAttributes(element: Swift.String)
        case invalidAttribute(element: Swift.String, name: Swift.String)
        case unhandledNode(Swift.String)
    }
}
