public import File_System
public import Xcode_Workspace_Standard

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
