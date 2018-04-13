import Vapor
import FluentProvider
import HTTP

final class LocationConnection: Model {
    let storage = Storage()

    var rootLocationID: Int
    var childLocationID: Int
    static let idType: IdentifierType = .int

    struct Keys {
        static let id = "id"
        static let rootLocationID = "rootLocationID"
        static let childLocationID = "childLocationID"
    }

    init(row: Row) throws {
        rootLocationID = try row.get(LocationConnection.Keys.rootLocationID)
        childLocationID = try row.get(LocationConnection.Keys.childLocationID)
    }

init(rootLocationID: Int, childLocationID: Int) {
        self.rootLocationID = rootLocationID
        self.childLocationID = childLocationID
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set(LocationConnection.Keys.rootLocationID, rootLocationID)
        try row.set(LocationConnection.Keys.childLocationID, childLocationID)
        return row
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
        try toReturn.set(LocationConnection.Keys.childLocationID, childLocationID)
        return toReturn
    }
}

extension LocationConnection: JSONInitializable {
    convenience init(json: JSON) throws {
        let rootLocationID: Int = try json.get(LocationConnection.Keys.rootLocationID)
        let childLocationID: Int = try json.get(LocationConnection.Keys.childLocationID)
        self.init(rootLocationID: rootLocationID, childLocationID: childLocationID)
    }
}

