import XCTest
import Foundation
@testable import RegexBuilder

final class NeatRegexTests: XCTestCase {
    func test_new() {
        struct Address {
            var zipCode: String? = nil
            var phone: String? = nil
        }
        var address = Address()
        
        NeatRegex(on: "  CA95014, (408) 6065775", store: &address) {
            Beginning(of: .line)
            ZeroOrMore(.space)
            Extract<Address>(storeAt: \.zipCode) {
                Exactly(2, .alphabet)
                Exactly(5, .digit)
            }
            ZeroOrMore(.space)
            Exactly(1, .literal(","))
            ZeroOrMore(.space)
            Extract<Address>(storeAt: \.phone) {
                Exactly(1, .literal("("))
                Exactly(3, .digit)
                Exactly(1, .literal(")"))
                ZeroOrMore(.space)
                Exactly(7, .digit)
            }
            End(of: .line)
        }
        
        XCTAssertEqual(address.zipCode, "CA95014")
        XCTAssertEqual(address.phone, "(408) 6065775")
    }
    
    func test_old_fashion() {
        struct Address {
            var zipCode: String? = nil
            var phone: String? = nil
        }
        
        var address = Address()
        let text = "  CA95014, (408) 6065775"
        let pattern = #"^\s*(\w{2}\d{5})\s*\,{1}\s*(\({1}\d{3}\){1}\s*\d{7})$"#
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.count))
        
        if let match = matches.first, match.numberOfRanges == 3 {
            let rangeZipCode = match.range(at: 1)
            let rangePhone = match.range(at: 2)
            
            if let zipCode = Range(rangeZipCode, in: text) {
                address.zipCode = String(text[zipCode])
            }
            
            if let rangePhone = Range(rangePhone, in: text) {
                address.phone = String(text[rangePhone])
            }
        }
        
        XCTAssertEqual(address.zipCode, "CA95014")
        XCTAssertEqual(address.phone, "(408) 6065775")
    }
}
