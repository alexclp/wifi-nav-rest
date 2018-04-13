import XCTest
import Testing
@testable import Vapor
@testable import App

class LocationTests: TestCase {
    func testInitWithValues() {
        let sampleLocation = Location.init(x: 1.0, y: 2.0, standardWidth: 3.0, standardHeight: 4.0, latitude: 43.3, longitude: 44.3, roomID: 1)
        XCTAssertEqual(sampleLocation.x, 1.0)
        XCTAssertEqual(sampleLocation.y, 2.0)
        XCTAssertEqual(sampleLocation.standardWidth, 3.0)
        XCTAssertEqual(sampleLocation.standardHeight, 4.0)
        XCTAssertEqual(sampleLocation.latitude, 43.3)
        XCTAssertEqual(sampleLocation.longitude, 44.3)
        XCTAssertEqual(sampleLocation.roomID, 1)
    }

    func testMakeRow() throws {
        let location = Location.init(x: 1.0, y: 2.0, standardWidth: 3.0, standardHeight: 4.0, latitude: 43.3, longitude: 44.3, roomID: 1)
        let row = try location.makeRow()
        XCTAssertEqual(try row.get("x"), 1.0)
        XCTAssertEqual(try row.get("y"), 2.0)
        XCTAssertEqual(try row.get("standardWidth"), 3.0)
        XCTAssertEqual(try row.get("standardHeight"), 4.0)
        XCTAssertEqual(try row.get("latitude"), 43.3)
        XCTAssertEqual(try row.get("longitude"), 44.3)
        XCTAssertEqual(try row.get("roomID"), 1)
    }
}

extension LocationTests {
    /// This is a requirement for XCTest on Linux
    /// to function properly.
    /// See ./Tests/LinuxMain.swift for examples
    static let allTests = [
        ("testInitWithValues", testInitWithValues),
        ("testMakeRow", testMakeRow),
    ]
}