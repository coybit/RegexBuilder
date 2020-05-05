import XCTest
@testable import RegexBuilder

final class RegexBuilderTests: XCTestCase {
    func test_simple_digit() {
        let r = RegexBuilder()
            .digit(.oneOrMore, of: .zeroToNine)
        XCTAssertEqual(r.regex, "\\d+")
    }

    func test_simple_character() {
        let r = RegexBuilder()
            .character(.zeroOrMore, of: [.lowerCaseAscii, .digit, .upperCaseAscii, .ideograph])
        XCTAssertEqual(r.regex, "\\w*")
    }
    
    func test_simple_space() {
        let r = RegexBuilder()
            .space(.exactly(1), of: [.space, .tab, .newline, .carriageReturn, .formFeed])
        XCTAssertEqual(r.regex, "\\s{1}")
    }
    
    func test_subset_space() {
        let r = RegexBuilder()
            .space(.exactly(1), of: [.space, .tab])
        XCTAssertEqual(r.regex, "[\\p{Z}\\t]{1}")
    }
    
    func test_composite_digit_space_character() {
        let r = RegexBuilder()
            .space(.exactly(1), of: [.space, .tab, .newline, .carriageReturn, .formFeed])
            .character(.zeroOrMore, of: [.lowerCaseAscii, .upperCaseAscii])
            .digit(.between(2, 4), of: .just([1,2,3]))
        XCTAssertEqual(r.regex, "\\s{1}[\\p{Ll}\\p{Lu}]*[123]{2,4}")
    }
    
    func test_simple_either() {
        let r = RegexBuilder()
            .either(
                RegexBuilder()
                    .digit(.exactly(1), of: .zeroToNine),
                RegexBuilder()
                    .space(.atMostOne, of: [.newline])
        )
        XCTAssertEqual(r.regex, "\\d{1}|\\n?")
    }
    
    func test_simple_not() {
        let r = RegexBuilder()
            .not(RegexBuilder()
                .space(.oneOrMore, of: [.newline])
        )
        XCTAssertEqual(r.regex, "[^\\n+]")
    }
    
    func test_email() {
        let r = RegexBuilder()
            .beginning(of: .line)
            .character(.oneOrMore, of: [
                .lowerCaseAscii,
                .upperCaseAscii,
                .digit,
                .underscore,
                .dash,
                .dot
            ])
            .character(.exactly(1), of: [.literal("@")])
            .character(.oneOrMore, of: [
                .lowerCaseAscii,
                .upperCaseAscii,
                .digit,
                .underscore,
                .dash,
                .dot
            ])
            .character(.exactly(1), of: [.dot])
            .character(.between(2, 5), of: [
                .lowerCaseAscii,
                .upperCaseAscii,
            ])
            .end(of: .line)
        
        XCTAssertEqual(r.regex, #"^[\-\.\p{Ll}\p{Lu}\p{Nd}_]+@{1}[\-\.\p{Ll}\p{Lu}\p{Nd}_]+\.{1}[\p{Ll}\p{Lu}]{2,5}$"#)
        XCTAssertEqual(matches(for: r.regex, in: "aa.com").count, 0)
        XCTAssertEqual(matches(for: r.regex, in: "aa.com@").count, 0)
        XCTAssertEqual(matches(for: r.regex, in: "aa@@a.com").count, 0)
        XCTAssertEqual(matches(for: r.regex, in: "aacom").count, 0)
        XCTAssertGreaterThan(matches(for: r.regex, in: "a_1.23-home@a_b.uss").count, 0)
        XCTAssertGreaterThan(matches(for: r.regex, in: "test@a.com").count, 0)
        XCTAssertGreaterThan(matches(for: r.regex, in: ".@a.test").count, 0)
    }
    
//    static var allTests = [
//        ("testExample", testExample),
//    ]
    
    private func matches(for regex: String, in text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}
