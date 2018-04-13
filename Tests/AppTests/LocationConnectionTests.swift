import XCTest
import Testing
@testable import Vapor
@testable import App

class LocationConnectionTests: TestCase {
    func testInitWithValues() {
        let locationConnection = LocationConnection.init(rootLocationID: 1, childLocationID: 2)
        XCTAssertEqual(locationConnection.rootLocationID, 1)
        XCTAssertEqual(locationConnection.childLocationID, 2)
    }

    func testMakeRow() throws {
        let locationConnection = LocationConnection.init(rootLocationID: 1, childLocationID: 2)
        let row = try locationConnection.makeRow()
        XCTAssertEqual(try row.get("rootLocationID"), 1)
        XCTAssertEqual(try row.get("childLocationID"), 2)
    }
}

extension LocationConnectionTests {
    /// This is a requirement for XCTest on Linux
    /// to function properly.
    /// See ./Tests/LinuxMain.swift for examples
    static let allTests = [
        ("testInitWithValues", testInitWithValues),
        ("testMakeRow", testMakeRow),
    ]
}