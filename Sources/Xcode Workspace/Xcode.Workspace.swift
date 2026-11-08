private import XML
public import Xcode_Workspace_Standard
public import File_System

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

extension Xcode.Workspace {
    public static func read(from directory: File.Directory) throws(Error) -> Self {
        let file = directory[file: "contents.xcworkspacedata"]
        guard file.stat.isFile else { throw .invalidBundle }

        let source: Swift.String
        do throws(Either<File.System.Read.Full.Error, Never>) {
            source = try file.read.full { bytes in
                var storage = [Byte]()
                storage.reserveCapacity(bytes.count)
                for index in bytes.indices {
                    storage.append(bytes[index])
                }
                return Swift.String(decoding: storage, as: Swift.UTF8.self)
            }
        } catch {
            throw .read
        }
        return try parse(source)
    }
}

extension Xcode.Workspace {

    public func write(to directory: File.Directory) throws(Error) {
        let bundle = directory.path
        do throws(File.System.Create.Directory.Error) {
            try File.System.Create.Directory.create(at: bundle, createIntermediates: true)
        } catch {
            throw .create
        }
        do throws(File.System.Write.Atomic.Error) {
            try File(bundle / "contents.xcworkspacedata").write.atomic(xml)
        } catch {
            throw .write
        }
    }
}

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
