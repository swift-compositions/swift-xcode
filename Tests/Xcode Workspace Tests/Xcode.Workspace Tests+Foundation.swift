import Foundation

enum WorkspaceFixture {

    static func institute() -> (directory: Swift.String, byteCount: Int, fnv1a64: UInt64)? {
        guard let url = Bundle.module.url(
            forResource: "contents",
            withExtension: "xcworkspacedata",
            subdirectory: "Fixtures/institute interim.xcworkspace"
        ), let data = try? Data(contentsOf: url) else { return nil }
        let digest = data.reduce(UInt64(0xcbf2_9ce4_8422_2325)) { hash, byte in
            (hash ^ UInt64(byte)) &* 0x0000_0100_0000_01B3
        }
        return (url.deletingLastPathComponent().path, data.count, digest)
    }
}
