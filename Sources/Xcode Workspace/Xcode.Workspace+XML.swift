private import XML
public import Xcode_Workspace_Standard

extension Xcode.Workspace {

    public var xml: Swift.String {
        let root = XML.element(
            "Workspace",
            attributes: [.init(name: "version", value: version)],
            children: references.map(Self.xml)
        )
        return XML.Document(version: .v1_0, encoding: "UTF-8", root: root).serialize(pretty: true)
    }

    private static func xml(_ reference: Reference) -> XML {
        switch reference {
        case .file(let location):
            XML.element(
                "FileRef",
                attributes: [.init(name: "location", value: location.rawValue)]
            )
        case .group(let group):
            XML.element(
                "Group",
                attributes: [
                    .init(name: "location", value: group.location.rawValue),
                    .init(name: "name", value: group.name),
                ],
                children: group.references.map(Self.xml)
            )
        }
    }
}
