import Vapor
import HTTP

final class LocationConnectionController: ResourceRepresentable {
    func index(_ req: Request) throws -> ResponseRepresentable {
        return try LocationConnection.all().makeJSON()
    }

    func store(_ req: Request) throws -> ResponseRepresentable {
        let loc = try req.createLocationConnection()
        try loc.save()
        return loc
    }

    func show(_ req: Request, locationConnection: LocationConnection) throws -> ResponseRepresentable {
        return locationConnection
    }

    func delete(_ req: Request, locationConnection: LocationConnection) throws -> ResponseRepresentable {
        try locationConnection.delete()
        return Response(status: .ok)
    }

    func clear(_ req: Request) throws -> ResponseRepresentable {
        try LocationConnection.makeQuery().delete()
        return Response(status: .ok)
    }

    func makeResource() -> Resource<LocationConnection> {
        return Resource(
            index: index,
            store: store,
            show: show,
            destroy: delete,
            clear: clear
        )
    }
}

extension LocationConnectionController: EmptyInitializable { }

extension Request {
    func createLocationConnection() throws -> LocationConnection {
        guard let json = json else { throw Abort.badRequest }
        return try LocationConnection(json: json)
    }
}