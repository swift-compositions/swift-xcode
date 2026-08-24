import Testing
import Xcode_Scheme

@Test
func `scheme serialization contains typed build and test entries`() {
    let reference = Xcode.Scheme.Reference(
        blueprint: "Workspace-Package",
        name: "Workspace-Package",
        container: "container:Application"
    )
    let scheme = Xcode.Scheme(
        build: [.init(reference: reference)],
        test: [.init(reference: reference, parallelizable: true)]
    )
    #expect(scheme.xml.contains("BuildActionEntry"))
    #expect(scheme.xml.contains("TestableReference"))
    #expect(scheme.xml.contains(#"parallelizable="YES""#))
}

@Test
func `no launch action is emitted, because xcodebuild segfaults on the stub`() {

    let reference = Xcode.Scheme.Reference(
        blueprint: "Workspace-Package",
        name: "Workspace-Package",
        container: "container:Application"
    )
    let xml = Xcode.Scheme(
        build: [.init(reference: reference)],
        test: [.init(reference: reference)]
    ).xml

    #expect(!xml.contains("LaunchAction"))
    #expect(xml.contains("BuildAction"))
    #expect(xml.contains("TestAction"))
    #expect(xml.contains("ProfileAction"))
    #expect(xml.contains("AnalyzeAction"))
    #expect(xml.contains("ArchiveAction"))
    #expect(xml.contains(#"parallelizable="NO""#))
}
