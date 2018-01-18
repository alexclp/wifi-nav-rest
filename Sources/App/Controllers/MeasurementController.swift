import Vapor
import HTTP

final class MeasurementController: ResourceRepresentable {
    func index(_ req: Request) throws -> ResponseRepresentable {
        return try Measurement.all().makeJSON()
    }

    func store(_ req: Request) throws -> ResponseRepresentable {
        let measurement = try req.createMeasurement()
        try measurement.save()
        return measurement
    }

    func show(_ req: Request, measurement: Measurement) throws -> ResponseRepresentable {
        return measurement
    }

    func delete(_ req: Request, measurement: Measurement) throws -> ResponseRepresentable {
        try measurement.delete()
        return Response(status: .ok)
    }

    func clear(_ req: Request) throws -> ResponseRepresentable {
        try Measurement.makeQuery().delete()
        return Response(status: .ok)
    }

    func makeResource() -> Resource<Measurement> {
        return Resource(
            index: index,
            store: store,
            show: show,
            destroy: delete,
            clear: clear
        )
    }
}

extension MeasurementController: EmptyInitializable { }

extension Request {
    func createMeasurement() throws -> Measurement {
        guard let json = json else { throw Abort.badRequest }
        return try Measurement(json: json)
    }
}
