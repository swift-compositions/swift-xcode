private import File_System
public import Xcode_Workspace_Standard

extension Xcode.Workspace {
    public static func read(from directory: Swift.String) throws(Error) -> Self {
        let bundle: File.Path
        do throws(File.Path.Error) {
            bundle = try File.Path(directory)
        } catch {
            throw .path
        }

        let file = File.Directory(bundle)[file: "contents.xcworkspacedata"]
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
