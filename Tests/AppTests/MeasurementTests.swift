import XCTest
import Testing
@testable import Vapor
@testable import App

class MeasurementTests: TestCase {
    func testInitWithValues() {
        let measurement = Measurement.init(signalStrength: -20, apID: 1, locationID: 2)
        XCTAssertEqual(measurement.signalStrength, -20)
        XCTAssertEqual(measurement.apID, 1)
        XCTAssertEqual(measurement.locationID, 2)
    }

    func testMakeRow() throws {
        let measurement = Measurement.init(signalStrength: -20, apID: 1, locationID: 2)
        let row = try measurement.makeRow()
        XCTAssertEqual(try row.get("signalStrength"), -20)
        XCTAssertEqual(try row.get("apID"), 1)
        XCTAssertEqual(try row.get("locationID"), 2)
    }
}

extension MeasurementTests {
    /// This is a requirement for XCTest on Linux
    /// to function properly.
    /// See ./Tests/LinuxMain.swift for examples
    static let allTests = [
        ("testInitWithValues", testInitWithValues),
        ("testMakeRow", testMakeRow),
    ]
}