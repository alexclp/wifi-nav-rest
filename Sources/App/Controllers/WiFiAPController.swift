import Vapor
import HTTP

final class WiFiAPController: ResourceRepresentable {
    func index(_ req: Request) throws -> ResponseRepresentable {
        return try WiFiAP.all().makeJSON()
    }

    func index(_ req: Request, macAddress: String) throws -> ResponseRepresentable {
        guard let ap = try WiFiAP.makeQuery().filter("macAddress", .equals, macAddress).first() else { throw Abort.badRequest }
        return ap
    }

    func store(_ req: Request) throws -> ResponseRepresentable {
        let ap = try req.createWiFiAP()
        try ap.save()
        return ap
    }

    func show(_ req: Request, ap: WiFiAP) throws -> ResponseRepresentable {
        return ap
    }

    func delete(_ req: Request, ap: WiFiAP) throws -> ResponseRepresentable {
        try ap.delete()
        return Response(status: .ok)
    }

    func clear(_ req: Request) throws -> ResponseRepresentable {
        try WiFiAP.makeQuery().delete()
        return Response(status: .ok)
    }

    func makeResource() -> Resource<WiFiAP> {
        return Resource(
            index: index,
            store: store,
            show: show,
            destroy: delete,
            clear: clear
        )
    }
}

extension WiFiAPController: EmptyInitializable { }

extension Request {
    func createWiFiAP() throws -> WiFiAP {
        guard let json = json else { throw Abort.badRequest }
        return try WiFiAP(json: json)
    }
}
