import Vapor
import FluentProvider
import HTTP

final class Location: Model {
    let storage = Storage()

    static let idType: IdentifierType = .int
    var x: Double
    var y: Double
    var standardWidth: Double
    var standardHeight: Double
    var latitude: Double
    var longitude: Double
    var roomID: Identifier

    struct Keys {
        static let id = "id"
        static let x = "x"
        static let y = "y"
        static let standardWidth = "standardWidth"
        static let standardHeight = "standardHeight"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let roomID = "roomID"
    }

    init(row: Row) throws {
        x = try row.get("x")
        y = try row.get("y")
        standardWidth = try row.get("standardWidth")
        standardHeight = try row.get("standardHeight")
        latitude = try row.get("latitude")
        longitude = try row.get("longitude")
        roomID = try row.get("roomID")
    }

    init(x: Double, y: Double, standardWidth: Double, standardHeight: Double, latitude: Double, longitude: Double, roomID: Identifier) {
        self.x = x
        self.y = y
        self.standardWidth = standardWidth
        self.standardHeight = standardHeight
        self.latitude = latitude
        self.longitude = longitude
        self.roomID = roomID
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Location.Keys.x, x)
        try row.set(Location.Keys.y, y)
        try row.set(Location.Keys.standardWidth, standardWidth)
        try row.set(Location.Keys.standardHeight, standardHeight)
        try row.set(Location.Keys.latitude, latitude)
        try row.set(Location.Keys.longitude, longitude)
        try row.set(Location.Keys.roomID, roomID)

        return row
    }

    func connectToPointsInCurrentRoom() throws {
        try self.save()
        let locations = try Location.makeQuery().filter("roomID", .equals, roomID).all()
        for location in locations {
            let roomLocationID = location.id
            print(id?.wrapped.int)
            print(roomLocationID?.wrapped.int)
            var locationConnection = LocationConnection.init(rootLocationID: (id!.wrapped.int)!, childLocationID: (roomLocationID!.wrapped.int)!)
            do {
                try locationConnection.save()
            } catch {
                print(error)
            }
        }
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
        try database.create(self) { builder in
            builder.id()
            builder.double("x")
            builder.double("y")
            builder.double("standardWidth")
            builder.double("standardHeight")
            builder.double("latitude")
            builder.double("longitude")
            builder.foreignId(for: Room.self, optional: false, unique: false, foreignIdKey: "roomID", foreignKeyName: "roomID")
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
        try toReturn.set(Location.Keys.x, x)
        try toReturn.set(Location.Keys.y, y)
        try toReturn.set(Location.Keys.standardWidth, standardWidth)
        try toReturn.set(Location.Keys.standardHeight, standardHeight)
        try toReturn.set(Location.Keys.latitude, latitude)
        try toReturn.set(Location.Keys.longitude, longitude)
        try toReturn.set(Location.Keys.roomID, roomID)

        return toReturn
    }
}

extension Location: JSONInitializable {
    convenience init(json: JSON) throws {
        let x: Double = try json.get(Location.Keys.x)
        let y: Double = try json.get(Location.Keys.y)
        let standardWidth: Double = try json.get(Location.Keys.standardWidth)
        let standardHeight: Double = try json.get(Location.Keys.standardHeight)
        let latitude: Double = try json.get(Location.Keys.latitude)
        let longitude: Double = try json.get(Location.Keys.longitude)
        let roomID: Identifier = try json.get(Location.Keys.roomID)
        self.init(x: x, y: y, standardWidth: standardWidth, standardHeight: standardHeight, latitude: latitude, longitude: longitude, roomID: roomID)
        try connectToPointsInCurrentRoom()
    }
}
