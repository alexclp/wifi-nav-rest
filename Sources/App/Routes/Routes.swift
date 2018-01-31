import Vapor

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

        try resource("posts", PostController.self)
        try resource("locations", LocationController.self)
        try resource("rooms", RoomController.self)
        try resource("accessPoints", WiFiAPController.self)
        try resource("measurements", MeasurementController.self)
    }
}
