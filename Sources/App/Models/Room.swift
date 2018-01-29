import Vapor
import FluentProvider
import HTTP

final class Room: Model {
    let storage = Storage()

    static let idType: IdentifierType = .int
    var name: String

    struct Keys {
        static let id = "id"
        static let name = "name"
    }

    init(row: Row) throws {
        name = try row.get("name")
    }

    init(name: String) {
        self.name = name
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", name)
        return row
    }
}

extension Room {
    var locations: Children<Room, Location> {
        return children()
    }
}

extension Room: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { room in
            room.id()
            room.string("name")
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

        return toReturn
    }
}

extension Room: JSONInitializable {
    convenience init(json: JSON) throws {
        let name: String = try json.get(Room.Keys.name)
        self.init(name: name)
    }
}
