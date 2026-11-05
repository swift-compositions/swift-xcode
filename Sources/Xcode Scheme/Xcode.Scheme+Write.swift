private import File_System
public import Xcode_Scheme_Standard

extension Xcode.Scheme {

    public func write(_ name: Swift.String, to workspace: Swift.String) throws(Error) {
        let directory: File.Path
        let file: File.Path.Component
        do throws(File.Path.Error) {
            directory = try File.Path(workspace) / "xcshareddata" / "xcschemes"
        } catch {
            throw .path
        }
        do throws(File.Path.Component.Error) {
            file = try File.Path.Component("\(name).xcscheme" as Swift.String)
        } catch {
            throw .path
        }
        do throws(File.System.Create.Directory.Error) {
            try File.System.Create.Directory.create(at: directory, createIntermediates: true)
        } catch {
            throw .create
        }
        do throws(File.System.Write.Atomic.Error) {
            try File(directory / file).write.atomic(xml)
        } catch {
            throw .write
        }
    }
}
