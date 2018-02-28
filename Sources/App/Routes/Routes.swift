import Vapor

struct LocationConnectionRequestJSON: Decodable {
    let locationID1: Int
    let locationID2: Int
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
            let loc = LocationConnection.init(rootLocationID: locations.locationID1, childLocationID: locations.locationID2)
            try loc.save()

            var responseJSON = JSON()
            try responseJSON.set("success", true)
            return try Response(status: .ok, json: responseJSON)
        }

        get("locationConnections", "id", ":id") { request in 
            guard let rootLocationID = request.parameters["id"]?.int else { throw Abort.badRequest }
            // print(rootLocationID)
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

        try resource("locations", LocationController.self)
        try resource("rooms", RoomController.self)
        try resource("accessPoints", WiFiAPController.self)
        try resource("measurements", MeasurementController.self)
        try resource("locationConnections", LocationConnectionController.self)
    }
}
