import XCTest
import Testing
@testable import Vapor
@testable import App

class WiFiAPTests: TestCase {
    func testInitWithValues() {
        let wifiAp = WiFiAP.init(name: "Test AP", macAddress: "AB:CD")
        XCTAssertEqual(wifiAp.name, "Test AP")
        XCTAssertEqual(wifiAp.macAddress, "AB:CD")
    }

    func testMakeRow() throws {
        let wifiAp = WiFiAP.init(name: "Test AP", macAddress: "AB:CD")
        let row = try wifiAp.makeRow()
        XCTAssertEqual(try row.get("name"), "Test AP")
        XCTAssertEqual(try row.get("macAddress"), "AB:CD")
    }
}

extension WiFiAPTests {
    /// This is a requirement for XCTest on Linux
    /// to function properly.
    /// See ./Tests/LinuxMain.swift for examples
    static let allTests = [
        ("testInitWithValues", testInitWithValues),
        ("testMakeRow", testMakeRow),
    ]
}