import Vapor
import HTTP
import FluentProvider

final class Measurement: Model {
    let storage = Storage()

    static let idType: IdentifierType = .uuid
    var signalStrength: Int
    var apID: Identifier
    var locationID: Identifier

    struct Keys {
        static let signalStrength = "signalStrength"
        static let apID = "apID"
        static let locationID = "locationID"
    }

    init(row: Row) throws {
        signalStrength = try row.get("signalStrength")
        apID = try row.get("signalStrength")
        locationID = try row.get("locationID")
    }

    init(signalStrength: Int, apID: Identifier, locationID: Identifier) {
        self.signalStrength = signalStrength
        self.apID = apID
        self.locationID = locationID
    }

    func makeRow() throws -> Row {
        var row = Row()

        try row.set("signalStrength", signalStrength)
        try row.set("apID", apID)
        try row.set("locationID", locationID)

        return row
    }
}

extension Measurement: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { measurements in
            measurements.id()
            measurements.int("signalStrength")
            measurements.foreignId(for: WiFiAP.self, optional: false, unique: true, foreignIdKey: "apID", foreignKeyName: "apID")
            measurements.foreignId(for: Location.self, optional: false, unique: true, foreignIdKey: "locationID", foreignKeyName: "locationID")
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Measurement {
    var ap: Parent<Measurement, WiFiAP> {
        return parent(id: apID)
    }

    var location: Parent<Measurement, Location> {
        return parent(id: locationID)
    }
}
