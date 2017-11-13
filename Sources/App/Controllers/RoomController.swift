import Vapor
import HTTP

final class RoomController: ResourceRepresentable {

}

extension RoomController: EmptyInitializable { }

extension Request {
    func createRoom() throws -> Room {
        guard let json = json else { throw Abort.badRequest }
        return try Room(json: json)
    }
}
