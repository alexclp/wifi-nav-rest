import Vapor
import FluentProvider
import HTTP

final class Room: Model {
    let storage = Storage()

    static let idType: IdentifierType = .uuid
    var name: String
    var locations: [Location]
    var map: [[Location]]

    init(row: Row) throws {
        name = try row.get("name")
        locations = try row.get("locations")
        map =  try row.get("map")
    }

    init(name: String) {
        self.name = name
        self.locations = [Location]()
        self.map = [[Location]]()
    }

    func addLocation(location: Location) {
        locations.append(location)
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", name)
        try row.set("locations", locations)
        try row.set("map", map)
        return row
    }
}

extension Room: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { rooms in
            rooms.id()
            rooms.custom("locations", type: "array")
            rooms.custom("map", type: "array")
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Room: JSONInitializable {
    convenience init(json: JSON) throws {

    }
}
