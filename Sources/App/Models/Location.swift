import Vapor
import FluentProvider
import HTTP

final class Location: Model {
    let storage = Storage()

    static let idType: IdentifierType = .uuid
    var latitude: Double
    var longitude: Double
    var pressure: Double

    init(row: Row) throws {
        latitude = try row.get("latitude")
        longitude = try row.get("longitude")
        pressure = try row.get("pressure")
    }

    init(latitude: Double, longitude: Double, pressure: Double) {
        self.latitude = latitude
        self.longitude = longitude
        self.pressure = pressure
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
