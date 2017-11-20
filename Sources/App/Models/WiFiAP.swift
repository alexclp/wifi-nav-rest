import Vapor
import FluentProvider
import HTTP

final class WiFiAP: Model {
    let storage = Storage()

    static let idType: IdentifierType = .uuid
    var name: String
    var macAddress: String
    var signalStrength: Double

    struct Keys {
        static let id = "id"
        static let name = "name"
        static let macAddress = "macAddress"
        static let signalStrength = "signalStrength"
    }

    init(row: Row) throws {
        name = try row.get("name")
        macAddress = try row.get("macAddress")
        signalStrength = try row.get("signalStrength")
    }

    init(name: String, macAddress: String, signalStrength: Double) {
        self.name = name
        self.macAddress = macAddress
        self.signalStrength = signalStrength
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", name)
        try row.set("macAddress", macAddress)
        try row.set("signalStrength", signalStrength)
        return row
    }
}

extension WiFiAP: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { accessPoints in
            accessPoints.id()
            accessPoints.string("name")
            accessPoints.string("macAddress")
            accessPoints.double("signalStrength")
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension WiFiAP: JSONConvertible {
    func makeJSON() throws -> JSON {
        var toReturn = JSON()

        try toReturn.set(WiFiAP.Keys.id, id)
        try toReturn.set(WiFiAP.Keys.name, name)
        try toReturn.set(WiFiAP.Keys.macAddress, macAddress)
        try toReturn.set(WiFiAP.Keys.signalStrength, signalStrength)

        return toReturn
    }
}

extension WiFiAP: JSONInitializable {
    convenience init(json: JSON) throws {
        let name: String = try json.get(WiFiAP.Keys.name)
        let macAddress: String = try json.get(WiFiAP.Keys.macAddress)
        let signalStrength: Double = try json.get(WiFiAP.Keys.signalStrength)
        self.init(name: name, macAddress: macAddress, signalStrength: signalStrength)
    }
}
