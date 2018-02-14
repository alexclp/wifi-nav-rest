import Vapor
import FluentProvider
import HTTP

final class Room: Model {
    let storage = Storage()

    static let idType: IdentifierType = .int
    var name: String
    var floorNumber: Int
    var roomConnectionID: Identifier = 0

    struct Keys {
        static let id = "id"
        static let name = "name"
        static let floorNumber = "floorNumber"
        static let roomConnectionID = "roomConnectionID"
    }

    init(row: Row) throws {
        name = try row.get("name")
        floorNumber = try row.get("floorNumber")
        roomConnectionID = try row.get("roomConnectionID")
    }

    init(name: String, floorNumber: Int, roomConnectionID: Identifier?) {
        self.name = name
        self.floorNumber = floorNumber
        if let id = roomConnectionID {
            self.roomConnectionID = id
        }
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", name)
        try row.set("floorNumber", floorNumber)
        try row.set("roomConnectionID", roomConnectionID)
        return row
    }
}

extension Room {
    var locations: Children<Room, Location> {
        return children()
    }

    var roomConnection: Parent<Room, RoomConnection> {
        return parent(id: roomConnectionID)
    }
}

extension Room: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { room in
            room.id()
            room.string("name")
            room.int("floorNumber")
            room.foreignId(for: RoomConnection.self, optional: true, foreignIdKey: "roomConnectionID", foreignKeyName: "roomConnectionID")
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Room: ResponseRepresentable { }

extension Room: JSONConvertible {
    func makeJSON() throws -> JSON {
        var toReturn = JSON()

        try toReturn.set(Room.Keys.id, id)
        try toReturn.set(Room.Keys.name, name)
        try toReturn.set(Room.Keys.floorNumber, floorNumber)
        try toReturn.set(Room.Keys.roomConnectionID, roomConnectionID)

        return toReturn
    }
}

extension Room: JSONInitializable {
    convenience init(json: JSON) throws {
        let name: String = try json.get(Room.Keys.name)
        let floorNumber: Int = try json.get(Room.Keys.floorNumber)
        let roomConnectionID: Identifier = try json.get(Room.Keys.roomConnectionID)
        self.init(name: name, floorNumber: floorNumber, roomConnectionID: roomConnectionID)
    }
}
