import CryptoKit
import Foundation

enum WorkspaceFixture {

    static func institute() -> (directory: Swift.String, byteCount: Int, sha256: Swift.String)? {
        guard let url = Bundle.module.url(
            forResource: "contents",
            withExtension: "xcworkspacedata",
            subdirectory: "Fixtures/institute interim.xcworkspace"
        ), let data = try? Data(contentsOf: url) else { return nil }
        let digest = SHA256.hash(data: data).map { byte in
            let component = Swift.String(byte, radix: 16)
            return component.count == 1 ? "0\(component)" : component
        }.joined()
        return (url.deletingLastPathComponent().path, data.count, digest)
    }
}
