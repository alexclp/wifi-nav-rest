import Vapor
import HTTP
import FluentProvider

final class Measurement: Model {
    let storage = Storage()

    static let idType: IdentifierType = .int
    var signalStrength: Int
    var apID: Identifier
    var locationID: Identifier

    struct Keys {
        static let id = "id"
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

extension Measurement: ResponseRepresentable { }

extension Measurement: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { measurements in
            measurements.id()
            measurements.int("signalStrength")
            measurements.foreignId(for: WiFiAP.self, optional: false, unique: false, foreignIdKey: "apID", foreignKeyName: "apID")
            measurements.foreignId(for: Location.self, optional: false, unique: false, foreignIdKey: "locationID", foreignKeyName: "locationID")
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

extension Measurement: JSONConvertible {
    func makeJSON() throws -> JSON {
        var toReturn = JSON()

        try toReturn.set(Measurement.Keys.id, id)
        try toReturn.set(Measurement.Keys.signalStrength, signalStrength)
        try toReturn.set(Measurement.Keys.locationID, locationID)
        try toReturn.set(Measurement.Keys.apID, apID)

        return toReturn
    }
}

extension Measurement: JSONInitializable {
    convenience init(json: JSON) throws {
        let signalStrength: Int = try json.get(Measurement.Keys.signalStrength)
        let apID: Identifier = try json.get(Measurement.Keys.apID)
        let locationID: Identifier = try json.get(Measurement.Keys.locationID)
        self.init(signalStrength: signalStrength, apID: apID, locationID: locationID)
    }
}
