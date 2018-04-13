#if os(Linux)

import XCTest
@testable import AppTests

XCTMain([
    // AppTests
    // testCase(PostControllerTests.allTests),
    testCase(LocationTests.allTests)
])

#endif
