#if os(Linux)

import XCTest
@testable import AppTests

XCTMain([
    // AppTests
    testCase(LocationTests.allTests),
    testCase(LocationConnectionTests.allTests),
    testCase(MeasurementTests.allTests),
    testCase(RoomTests.allTests),
    testCase(WiFiAPTests.allTests),
])

#endif
