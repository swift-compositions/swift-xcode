import Testing
import Xcode_Workspace

@Test
func `workspace serialization uses XML escaping`() {
    let workspace = Xcode.Workspace(references: [
        .file(.init(scheme: .group, path: "Packages/a&b"))
    ])
    #expect(workspace.xml.contains("location=\"group:Packages/a&amp;b\""))
}

@Test
func `workspace parsing preserves order hierarchy and location schemes`() throws {
    let workspace = try Xcode.Workspace.parse(
        """
        <?xml version="1.0" encoding="UTF-8"?>
        <Workspace version="1.0">
          <FileRef location="group:First"></FileRef>
          <Group location="container:" name="Nested">
            <FileRef location="future:Second"></FileRef>
          </Group>
          <FileRef location="absolute:/Third"></FileRef>
        </Workspace>
        """
    )

    #expect(
        workspace == Xcode.Workspace(references: [
            .file(.init(scheme: .group, path: "First")),
            .group(
                .init(
                    name: "Nested",
                    location: .init(scheme: .container, path: ""),
                    references: [
                        .file(
                            .init(
                                scheme: .other(.init(rawValue: "future")!),
                                path: "Second"
                            )
                        )
                    ]
                )
            ),
            .file(.init(scheme: .absolute, path: "/Third")),
        ])
    )
}

@Test
func `workspace parsing fails on malformed XML`() {
    #expect(throws: Xcode.Workspace.Error.malformedXML) {
        try Xcode.Workspace.parse("<Workspace>")
    }
}

@Test
func `workspace parsing fails on invalid attributes`() {
    #expect(throws: Xcode.Workspace.Error.invalidAttributes(element: "FileRef")) {
        try Xcode.Workspace.parse(
            "<Workspace version=\"1.0\"><FileRef location=\"group:A\" extra=\"x\"/></Workspace>"
        )
    }
}

@Test
func `workspace parsing fails on unhandled nodes`() {
    #expect(throws: Xcode.Workspace.Error.unhandledNode("Unknown")) {
        try Xcode.Workspace.parse("<Workspace version=\"1.0\"><Unknown/></Workspace>")
    }
}

@Test
func `workspace serialization structurally round trips`() throws {
    let original = Xcode.Workspace(references: [
        .group(
            .init(
                name: "Packages",
                location: .init(scheme: .container, path: ""),
                references: [.file(.init(scheme: .group, path: "a&b"))]
            )
        )
    ])

    #expect(try Xcode.Workspace.parse(original.xml) == original)
}

@Test
func `supplied Institute workspace parses exactly`() throws {
    let fixture = try #require(WorkspaceFixture.institute())
    #expect(fixture.byteCount == 37_944)
    #expect(fixture.fnv1a64 == 0x83b2_324d_0407_cc8a)

    let workspace = try Xcode.Workspace.read(from: fixture.directory)
    #expect(workspace.references.count == 416)

    var groups = 0
    var containers = 0
    for reference in workspace.references {
        guard case .file(let location) = reference else { continue }
        switch location.scheme {
        case .group: groups += 1
        case .container: containers += 1
        default: break
        }
    }
    #expect(groups == 370)
    #expect(containers == 46)
}

@Test
func `workspace reading rejects an invalid bundle`() {
    #expect(throws: Xcode.Workspace.Error.invalidBundle) {
        try Xcode.Workspace.read(from: "/path/that/does/not/exist.xcworkspace")
    }
}
