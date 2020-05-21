import XCTest
import Foundation
@testable import RegexBuilder

final class NeatRegexTests: XCTestCase {
    func test() {
        let c = NeatRegex {
            Beginning(of: .line)
            ZeroOrMore(.digit)
            Exactly(2, .character)
            Between(2, and: 3, .space)
            End(of: .line)
        }
        
        XCTAssertEqual(c.pattern, #"^\d+\w{2}\s{2,3}$"#)
    }
}
