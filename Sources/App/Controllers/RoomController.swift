import Vapor
import HTTP

final class RoomController: ResourceRepresentable {
    func index(_ req: Request) throws -> ResponseRepresentable {
        return try Room.all().makeJSON()
    }

    func store(_ req: Request) throws -> ResponseRepresentable {
        let room = try req.createRoom()
        try room.save()
        return room
    }

    func show(_ req: Request, room: Room) throws -> ResponseRepresentable {
        return room
    }

    func delete(_ req: Request, room: Room) throws -> ResponseRepresentable {
        try room.delete()
        return Response(status: .ok)
    }

    func clear(_ req: Request) throws -> ResponseRepresentable {
        try Room.makeQuery().delete()
        return Response(status: .ok)
    }

    func makeResource() -> Resource<Room> {
        return Resource(
            index: index,
            store: store,
            show: show,
            destroy: delete,
            clear: clear
        )
    }
}

extension RoomController: EmptyInitializable { }

extension Request {
    func createRoom() throws -> Room {
        guard let json = json else { throw Abort.badRequest }
        return try Room(json: json)
    }
}
