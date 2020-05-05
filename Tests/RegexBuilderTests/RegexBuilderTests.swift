import XCTest
@testable import RegexBuilder

final class RegexBuilderTests: XCTestCase {
    func testExample() {
        XCTAssertEqual(RegexBuilder().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
