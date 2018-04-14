import Vapor

struct LocationConnectionRequestJSON: Decodable {
    let locationID1: Int
    let locationID2: Int
}

struct RoomSearchQueryJSON: Decodable {
    let query: String
    let floorNumber: Int
}

struct ClosestLocationsJSON: Decodable {
    let locationID: Int
} 

extension Droplet {
    func setupRoutes() throws {
        get("hello") { req in
            var json = JSON()
            try json.set("hello", "world")
            return json
        }

        get("plaintext") { req in
            return "Hello, world!"
        }

        // response to requests to /info domain
        // with a description of the request
        get("info") { req in
            return req.description
        }

        get("description") { req in return req.description }

        get("accessPoints", "address", ":macAddress") { request in
            guard let macAddress = request.parameters["macAddress"]?.string else { throw Abort.badRequest }
            guard let ap = try WiFiAP.makeQuery().filter("macAddress", .equals, macAddress).first() else { throw Abort.notFound }
            return try ap.makeJSON()
        }

        get("rooms", "floor", ":floorNumber") { request in
            guard let floorNumber = request.parameters["floorNumber"]?.int else { throw Abort.badRequest }
            let rooms = try Room.makeQuery().filter("floorNumber", .equals, floorNumber).all()
            return try rooms.makeJSON()
        }

        get("locations", "floor", ":floorNumber") { request in
            guard let floorNumber = request.parameters["floorNumber"]?.int else { throw Abort.badRequest }
            let rooms = try Room.makeQuery().filter("floorNumber", .equals, floorNumber).all()
            var toReturn = [Location]()
            for room in rooms {
                let locations = try Location.makeQuery().filter("roomID", .equals, room.id).all()
                toReturn += locations
            }
            return try toReturn.makeJSON()
        }

        get("measurements", "address", ":macAddress") { request in 
            guard let macAddress = request.parameters["macAddress"]?.string else { throw Abort.badRequest }
            guard let accessPoint = try WiFiAP.makeQuery().filter("macAddress", .equals, macAddress).first() else { throw Abort.notFound }
            let measurements = try Measurement.makeQuery().filter("apID", .equals, accessPoint.id).all()
            var responseJSON = JSON()
            try responseJSON.set("results", try measurements.makeJSON())
            return responseJSON
        }

        delete("rooms", "clearData", ":id") { request in
            guard let roomID = request.parameters["id"]?.int else { throw Abort.badRequest }
            if try Room.makeQuery().filter("id", .equals, roomID).all().count == 0 { 
                throw Abort.notFound 
            }
            let locations = try Location.makeQuery().filter("roomID", .equals, roomID).all()
            for location in locations {
                let measurements = try Measurement.makeQuery().filter("locationID", .equals, location.id).all()
                for measurement in measurements {
                    try measurement.delete()
                }
                try location.delete()
            }
            var responseJSON = JSON()
            try responseJSON.set("success", true)
            return try Response(status: .ok, json: responseJSON)
        }

        post("linkLocations") { request in 
            let locations = try request.decodeJSONBody(LocationConnectionRequestJSON.self)
            let loc1 = LocationConnection.init(rootLocationID: locations.locationID1, childLocationID: locations.locationID2)
            try loc1.save()
            let loc2 = LocationConnection.init(rootLocationID: locations.locationID2, childLocationID: locations.locationID1)
            try loc2.save()
            var responseJSON = JSON()
            try responseJSON.set("success", true)
            return try Response(status: .ok, json: responseJSON)
        }

        get("locationConnections", "id", ":id") { request in 
            guard let rootLocationID = request.parameters["id"]?.int else { throw Abort.badRequest }
            let connections = try LocationConnection.makeQuery().filter("rootLocationID", .equals, rootLocationID).all()
            return try connections.makeJSON()
        }

        get("linkRoomLocations") { request in
            let rooms = try Room.makeQuery().filter("id", .greaterThan, 0).all()
            for room in rooms {
                let roomID = room.id
                let locations = try Location.makeQuery().filter("roomID", .equals, roomID).all()
                for rootLocation in locations {
                    for location in locations {
                        let locCon = LocationConnection.init(rootLocationID: (rootLocation.id!.wrapped.int)!, childLocationID: (location.id!.wrapped.int)!)
                        try locCon.save()
                    }
                }
            }

            var responseJSON = JSON()
            try responseJSON.set("success", true)
            return try Response(status: .ok, json: responseJSON)
        }

        post("rooms", "search") { request in 
            let json = try request.decodeJSONBody(RoomSearchQueryJSON.self)
            let results = try Room.makeQuery().filter(raw: "name LIKE '\(json.query)%' AND floorNumber='\(json.floorNumber)'").all()

            return try results.makeJSON()
        }

        get("rooms", "connectingLocation", ":id") { request in 
            guard let roomID = request.parameters["id"]?.int else { throw Abort.badRequest } 
            let locationsInRoom = try Location.makeQuery().filter("roomID", .equals, roomID).all()
            for location in locationsInRoom {
                let connections = try LocationConnection.makeQuery().filter("rootLocationID", .equals, location.id).all()
            }
            for location in locationsInRoom {
                var connections = try LocationConnection.makeQuery().filter("rootLocationID", .equals, location.id).all()
                connections += try LocationConnection.makeQuery().filter("childLocationID", .equals, location.id).all()
                for connection in connections {
                    let rootID = connection.rootLocationID
                    let childID = connection.childLocationID
                    if let rootLoc = try Location.makeQuery().filter("id", .equals, rootID).first(), let childLoc = try Location.makeQuery().filter("id", .equals, childID).first() {
                        if rootLoc.roomID.wrapped.int! != roomID && childLoc.roomID.wrapped.int! == roomID {
                            return try childLoc.makeJSON()
                        } else if rootLoc.roomID.wrapped.int! == roomID && childLoc.roomID.wrapped.int != roomID {
                            return try rootLoc.makeJSON()
                        }
                    }
                }
            }
            
            var responseJSON = JSON()
            try responseJSON.set("error", "room is not connected to anything")
            return try Response(status: .notFound, json: responseJSON)
        }

        post("closestLocations") { request in
            let json = try request.decodeJSONBody(ClosestLocationsJSON.self)
            let currentLocation = try Location.makeQuery().filter("id", .equals, json.locationID).first()!
            let currentRoom = try Room.makeQuery().filter("id", .equals, currentLocation.roomID).first()!
            let rooms = try Room.makeQuery().and { andGroup in
                try andGroup.filter("id", .greaterThan, 0)
                try andGroup.filter("floorNumber", .equals, currentRoom.floorNumber)
                try andGroup.filter("id", .notEquals, currentRoom.id)
            }
            .all()

            var toReturn = [String: Location]()

            for room in rooms {
                let locationsInRoom = try Location.makeQuery().filter("roomID", .equals, room.id).all()
                var minDist = 9999999999.0
                for location in locationsInRoom {
                    let currentDist = Utils.haversineDistance(la1: currentLocation.latitude, lo1: currentLocation.longitude, la2: location.latitude, lo2: location.longitude)
                    if minDist > currentDist {
                        minDist = currentDist
                        toReturn[room.name] = location
                    }
                }
            }

            var responseJSON = JSON()
            for (roomName, location) in toReturn {
                responseJSON[DotKey(roomName)] = try location.makeJSON()
            }

            return try Response(status: .ok, json: responseJSON)
        }

        try resource("locations", LocationController.self)
        try resource("rooms", RoomController.self)
        try resource("accessPoints", WiFiAPController.self)
        try resource("measurements", MeasurementController.self)
        try resource("locationConnections", LocationConnectionController.self)
    }
}
