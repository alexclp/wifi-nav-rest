import Vapor
import FluentProvider
import HTTP

final class WiFiAP: Model {
    let storage = Storage()

    static let idType: IdentifierType = .uuid
    var name: String
    var macAddress: String

    struct Keys {
        static let id = "id"
        static let name = "name"
        static let macAddress = "macAddress"
    }

    init(row: Row) throws {
        name = try row.get("name")
        macAddress = try row.get("macAddress")
    }

    init(name: String, macAddress: String) {
        self.name = name
        self.macAddress = macAddress
    }

    func makeRow() throws -> Row {
        var row = Row()

        try row.set("name", name)
        try row.set("macAddress", macAddress)

        return row
    }
}

extension WiFiAP: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { accessPoints in
            accessPoints.id()
            accessPoints.string("name")
            accessPoints.string("macAddress")
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension WiFiAP: ResponseRepresentable { }

extension WiFiAP: JSONConvertible {
    func makeJSON() throws -> JSON {
        var toReturn = JSON()

        try toReturn.set(WiFiAP.Keys.id, id)
        try toReturn.set(WiFiAP.Keys.name, name)
        try toReturn.set(WiFiAP.Keys.macAddress, macAddress)

        return toReturn
    }
}

extension WiFiAP: JSONInitializable {
    convenience init(json: JSON) throws {
        let name: String = try json.get(WiFiAP.Keys.name)
        let macAddress: String = try json.get(WiFiAP.Keys.macAddress)
        self.init(name: name, macAddress: macAddress)
    }
}

extension WiFiAP {
    var measurements: Children<WiFiAP, Measurement> {
        return children()
    }
}
