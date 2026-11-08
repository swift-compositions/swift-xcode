private import XML
public import Xcode_Workspace_Standard

extension Xcode.Workspace {
    public static func parse(_ source: Swift.String) throws(Error) -> Self {
        let document: XML.Document
        do throws(XML.Error) {
            document = try XML.parse(source)
        } catch {
            throw .malformedXML
        }

        let root = document.root
        guard root.element.name == "Workspace" else {
            throw .invalidRoot(root.element.name)
        }
        try attributes(root, exactly: ["version"])
        guard let version = root.attributes["version"], !version.isEmpty else {
            throw .invalidAttribute(element: "Workspace", name: "version")
        }

        return Self(
            version: version,
            references: try root.children().map(reference)
        )
    }

    private static func reference(_ xml: XML) throws(Error) -> Reference {
        switch xml.element.name {
        case "FileRef":
            try attributes(xml, exactly: ["location"])
            guard xml.children().isEmpty,
                let raw = xml.attributes["location"],
                let location = Xcode.Workspace.Location(rawValue: raw)
            else {
                throw .invalidAttribute(element: "FileRef", name: "location")
            }
            return .file(location)

        case "Group":
            try attributes(xml, exactly: ["location", "name"])
            guard let name = xml.attributes["name"], !name.isEmpty else {
                throw .invalidAttribute(element: "Group", name: "name")
            }
            guard let raw = xml.attributes["location"],
                let location = Xcode.Workspace.Location(rawValue: raw)
            else {
                throw .invalidAttribute(element: "Group", name: "location")
            }
            return .group(
                .init(
                    name: name,
                    location: location,
                    references: try xml.children().map(reference)
                )
            )

        default:
            throw .unhandledNode(xml.element.name)
        }
    }

    private static func attributes(_ xml: XML, exactly names: Set<Swift.String>) throws(Error) {
        guard Set(xml.attributes.all.keys) == names else {
            throw .invalidAttributes(element: xml.element.name)
        }
    }
}
