import Vapor
import FluentProvider
import HTTP

final class Location: Model {
    let storage = Storage()

    static let idType: IdentifierType = .int
    var latitude: Double
    var longitude: Double
    var pressure: Double
    var roomID: Identifier

    struct Keys {
        static let id = "id"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let pressure = "pressure"
        static let roomID = "roomID"
    }

    init(row: Row) throws {
        latitude = try row.get("latitude")
        longitude = try row.get("longitude")
        pressure = try row.get("pressure")
        roomID = try row.get("roomID")
    }

    init(latitude: Double, longitude: Double, pressure: Double, roomID: Identifier) {
        self.latitude = latitude
        self.longitude = longitude
        self.pressure = pressure
        self.roomID = roomID
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set("latitude", latitude)
        try row.set("longitude", latitude)
        try row.set("pressure", pressure)
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
            locations.double("latitude")
            locations.double("longitude")
            locations.double("pressure")
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
        try toReturn.set(Location.Keys.latitude, latitude)
        try toReturn.set(Location.Keys.longitude, longitude)
        try toReturn.set(Location.Keys.pressure, pressure)
        try toReturn.set(Location.Keys.roomID, roomID)

        return toReturn
    }
}

extension Location: JSONInitializable {
    convenience init(json: JSON) throws {
        let latitude: Double = try json.get(Location.Keys.latitude)
        let longitude: Double = try json.get(Location.Keys.longitude)
        let pressure: Double = try json.get(Location.Keys.pressure)
        let roomID: Identifier = try json.get(Location.Keys.roomID)
        self.init(latitude: latitude, longitude: longitude, pressure: pressure, roomID: roomID)
    }
}
