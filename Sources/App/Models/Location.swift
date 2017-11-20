import Vapor
import FluentProvider
import HTTP

final class Location: Model {
    let storage = Storage()

    static let idType: IdentifierType = .uuid
    var latitude: Double
    var longitude: Double
    var pressure: Double
    var accessPoint: WiFiAP

    struct Keys {
        static let id = "id"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let pressure = "pressure"
        static let accessPoint = "accessPoint"
    }

    init(row: Row) throws {
        latitude = try row.get("latitude")
        longitude = try row.get("longitude")
        pressure = try row.get("pressure")
        accessPoint = try row.get("accessPoint")
    }

    init(latitude: Double, longitude: Double, pressure: Double, accessPoint: WiFiAP) {
        self.latitude = latitude
        self.longitude = longitude
        self.pressure = pressure
        self.accessPoint = accessPoint
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set("latitude", latitude)
        try row.set("longitude", latitude)
        try row.set("pressure", pressure)
        return row
    }
}

extension Location: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { locations in
            locations.id()
            locations.double("latitude")
            locations.double("longitude")
            locations.double("pressure")
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
        try toReturn.set(Location.Keys.accessPoint, accessPoint)

        return toReturn
    }
}

extension Location: JSONInitializable {
    convenience init(json: JSON) throws {
        let latitude: Double = try json.get(Location.Keys.latitude)
        let longitude: Double = try json.get(Location.Keys.longitude)
        let pressure: Double = try json.get(Location.Keys.pressure)
        let accessPoint: WiFiAP = try json.get(Location.Keys.accessPoint)
        self.init(latitude: latitude, longitude: longitude, pressure: pressure, accessPoint: accessPoint)
    }
}
