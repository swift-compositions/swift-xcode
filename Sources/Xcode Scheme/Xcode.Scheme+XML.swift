private import XML
public import Xcode_Scheme_Standard

extension Xcode.Scheme {

    public var xml: Swift.String {
        let root = XML.element(
            "Scheme",
            attributes: [
                .init(name: "LastUpgradeVersion", value: "2650"),
                .init(name: "version", value: version),
            ],
            children: [
                buildAction,
                testAction,

                XML.element(
                    "ProfileAction",
                    attributes: [.init(name: "buildConfiguration", value: "Release")]
                ),
                XML.element(
                    "AnalyzeAction",
                    attributes: [.init(name: "buildConfiguration", value: "Debug")]
                ),
                XML.element(
                    "ArchiveAction",
                    attributes: [
                        .init(name: "buildConfiguration", value: "Release"),
                        .init(name: "revealArchiveInOrganizer", value: "YES"),
                    ]
                ),
            ]
        )
        return XML.Document(version: .v1_0, encoding: "UTF-8", root: root).serialize(pretty: true)
    }

    private var buildAction: XML {
        XML.element(
            "BuildAction",
            attributes: [
                .init(name: "parallelizeBuildables", value: "YES"),
                .init(name: "buildImplicitDependencies", value: "YES"),
            ],
            children: [
                XML.element("BuildActionEntries", children: build.map { entry($0.reference) })
            ]
        )
    }

    private var testAction: XML {
        XML.element(
            "TestAction",
            attributes: action(configuration: "Debug"),
            children: [
                XML.element(
                    "Testables",
                    children: test.map { item in
                        XML.element(
                            "TestableReference",
                            attributes: [
                                .init(name: "skipped", value: item.skipped ? "YES" : "NO"),
                                .init(
                                    name: "parallelizable",
                                    value: item.parallelizable ? "YES" : "NO"
                                ),
                            ],
                            children: [node(item.reference)]
                        )
                    }
                )
            ]
        )
    }

    private func entry(_ value: Reference) -> XML {
        XML.element(
            "BuildActionEntry",
            attributes: [
                "buildForTesting", "buildForRunning", "buildForProfiling", "buildForArchiving",
                "buildForAnalyzing",
            ].map {
                .init(name: $0, value: "YES")
            },
            children: [node(value)]
        )
    }

    private func node(_ value: Reference) -> XML {
        XML.element(
            "BuildableReference",
            attributes: [
                .init(name: "BuildableIdentifier", value: value.identifier),
                .init(name: "BlueprintIdentifier", value: value.blueprint),
                .init(name: "BuildableName", value: value.name),
                .init(name: "BlueprintName", value: value.name),
                .init(name: "ReferencedContainer", value: value.container),
            ]
        )
    }

    private func action(configuration: Swift.String) -> [XML.Attribute] {
        [
            .init(name: "buildConfiguration", value: configuration),
            .init(
                name: "selectedDebuggerIdentifier",
                value: "Xcode.DebuggerFoundation.Debugger.LLDB"
            ),
            .init(
                name: "selectedLauncherIdentifier",
                value: "Xcode.DebuggerFoundation.Launcher.LLDB"
            ),
            .init(name: "shouldUseLaunchSchemeArgsEnv", value: "YES"),
        ]
    }
}
