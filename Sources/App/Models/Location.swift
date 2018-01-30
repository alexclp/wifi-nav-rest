import Vapor
import FluentProvider
import HTTP

final class Location: Model {
    let storage = Storage()

    static let idType: IdentifierType = .int
    var x: Double
    var y: Double
    var floorNumber: Int
    var roomID: Identifier

    struct Keys {
        static let id = "id"
        static let x = "x"
        static let y = "y"
        static let floorNumber = "floorNumber"
        static let roomID = "roomID"
    }

    init(row: Row) throws {
        x = try row.get("x")
        y = try row.get("y")
        floorNumber = try row.get("floorNumber")
        roomID = try row.get("roomID")
    }

    init(x: Double, y: Double, floorNumber: Int, roomID: Identifier) {
        self.x = x
        self.y = y
        self.floorNumber = floorNumber
        self.roomID = roomID
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set("x", x)
        try row.set("y", y)
        try row.set("floorNumber", floorNumber)
        try row.set("roomID", roomID)
        return row
    }
}

extension Location {
    var room: Parent<Location, Room> {
        return parent(id: roomID)
    }

    var measurements: Children<Location, Measurement> {
        return children()
    }
}

extension Location: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { locations in
            locations.id()
            locations.double("x")
            locations.double("y")
            locations.int("floorNumber")
            locations.foreignId(for: Room.self, optional: false, unique: true, foreignIdKey: "roomID", foreignKeyName: "roomID")
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Location: ResponseRepresentable { }

extension Location: JSONConvertible {
    func makeJSON() throws -> JSON {
        var toReturn = JSON()

        try toReturn.set(Location.Keys.id, id)
        try toReturn.set(Location.Keys.x, x)
        try toReturn.set(Location.Keys.y, y)
        try toReturn.set(Location.Keys.floorNumber, floorNumber)
        try toReturn.set(Location.Keys.roomID, roomID)

        return toReturn
    }
}

extension Location: JSONInitializable {
    convenience init(json: JSON) throws {
        let x: Double = try json.get(Location.Keys.x)
        let y: Double = try json.get(Location.Keys.y)
        let floorNumber: Int = try json.get(Location.Keys.floorNumber)
        let roomID: Identifier = try json.get(Location.Keys.roomID)
        self.init(x: x, y: y, floorNumber: floorNumber, roomID: roomID)
    }
}
