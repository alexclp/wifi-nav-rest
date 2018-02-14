import Vapor
import FluentProvider
import HTTP

final class LocationConnection: Model {
    let storage = Storage()

    var rootLocationID: Int
    static let idType: IdentifierType = .int

    struct Keys {
        static let id = "id"
        static let rootLocationID = "rootLocationID"
    }

    init(row: Row) throws {
        rootLocationID = try row.get(LocationConnection.Keys.rootLocationID)
    }

    init(rootLocationID: Int) {
        self.rootLocationID = rootLocationID
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set(LocationConnection.Keys.rootLocationID, rootLocationID)
        return row
    }
}

extension LocationConnection {
    var measurements: Children<LocationConnection, Location> {
        return children()
    }
}

extension LocationConnection: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in 
            builder.id()
            builder.int(LocationConnection.Keys.rootLocationID)
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension LocationConnection: ResponseRepresentable { }

extension LocationConnection: JSONConvertible {
    func makeJSON() throws -> JSON {
        var toReturn = JSON()
        try toReturn.set(LocationConnection.Keys.rootLocationID, rootLocationID)
        return toReturn
    }
}

extension LocationConnection: JSONInitializable {
    convenience init(json: JSON) throws {
        let rootLocationID: Int = try json.get(LocationConnection.Keys.rootLocationID)
        self.init(rootLocationID: rootLocationID)
    }
}

