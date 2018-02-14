import Vapor
import FluentProvider
import HTTP

final class RoomConnection: Model {
    let storage = Storage()

    static let idType: IdentifierType = .int

    var rootRoomID: Int

    struct Keys {
        static let id = "id"
        static let rootRoomID = "rootRoomID"
    }

    init(row: Row) throws {
        rootRoomID = try row.get("rootRoomID")
    }

    init(rootRoomID: Int) {
        self.rootRoomID = rootRoomID
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set("rootRoomID", rootRoomID)
        return row
    }
}

extension RoomConnection: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in 
            builder.id()
            builder.int("rootRoomID")
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension RoomConnection {
    var connections: Children<RoomConnection, Room> {
        return children()
    }
}

extension RoomConnection: ResponseRepresentable { }

extension RoomConnection: JSONConvertible {
    func makeJSON() throws -> JSON {
        var toReturn = JSON()

        try toReturn.set(RoomConnection.Keys.id, id)
        try toReturn.set("connections", connections)

        return toReturn
    }
}

extension RoomConnection: JSONInitializable {
    convenience init(json: JSON) throws {
        let rootRoomID: Int = try json.get(RoomConnection.Keys.rootRoomID)
        self.init(rootRoomID: rootRoomID)
    }
}