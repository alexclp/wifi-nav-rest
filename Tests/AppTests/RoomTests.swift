import XCTest
import Testing
@testable import Vapor
@testable import App

class RoomTests: TestCase {
    func testInitWithValues() {
        let room = Room.init(name: "Test Room", floorNumber: 7)
        XCTAssertEqual(room.name, "Test Room")
        XCTAssertEqual(room.floorNumber, 7)
    }

    func testMakeRow() throws {
        let room = Room.init(name: "Test Room", floorNumber: 7)
        let row = try room.makeRow()
        XCTAssertEqual(try row.get("name"), "Test Room")
        XCTAssertEqual(try row.get("floorNumber"), 7)
    }
}

extension RoomTests {
    /// This is a requirement for XCTest on Linux
    /// to function properly.
    /// See ./Tests/LinuxMain.swift for examples
    static let allTests = [
        ("testInitWithValues", testInitWithValues),
        ("testMakeRow", testMakeRow),
    ]
}