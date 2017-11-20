import Vapor
import FluentProvider
import HTTP

final class Room: Model {
    let storage = Storage()

    static let idType: IdentifierType = .uuid
    var name: String
    var locations: [Location]

    struct Keys {
        static let id = "id"
        static let name = "name"
        static let locations = "locations"
    }

    init(row: Row) throws {
        name = try row.get("name")
        locations = try row.get("locations")
    }

    init(name: String) {
        self.name = name
        self.locations = [Location]()
    }

    func addLocation(location: Location) {
        locations.append(location)
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", name)
        try row.set("locations", locations)
        return row
    }
}

extension Room: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { rooms in
            rooms.id()
            rooms.custom("locations", type: "array")
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
        try toReturn.set(Room.Keys.locations, locations)

        return toReturn
    }
}

extension Room: JSONInitializable {
    convenience init(json: JSON) throws {
        let name: String = try json.get(Room.Keys.name)
        self.init(name: name)
    }
}
