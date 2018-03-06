import Vapor
import FluentProvider

final class AddChildLocationIDMigration: Preparation {
    static func prepare(_ database: Database) throws {
        try database.modify(LocationConnection.self) { builder in
            builder.int(LocationConnection.Keys.childLocationID)
        }
    }
    
    static func revert(_ database: Database) throws { }
}