import Foundation

typealias RegexPattern = String

protocol RegexElement {
    var pattern: RegexPattern { get }
}

enum PatternAnchor {
    case line
}

enum CharacterClass {
    case digit
    case space
    case character
    
    var string: String {
        switch self {
        case .digit: return "\\d"
        case .space: return "\\s"
        case .character: return "\\w"
        }
    }
}


struct Beginning: RegexElement {
    let pattern: RegexPattern
    
    init(of anchor: PatternAnchor) {
        self.pattern = RegexPattern("^")
    }
}

struct End: RegexElement {
    let pattern: RegexPattern
    
    init(of anchor: PatternAnchor) {
        self.pattern = RegexPattern("$")
    }
}

struct ZeroOrMore: RegexElement {
    let pattern: RegexPattern
    
    init(_ characterClass: CharacterClass) {
        self.pattern = RegexPattern("\(characterClass.string)+")
    }
}

struct OneOrMore: RegexElement {
    let pattern: RegexPattern
    
    init(_ characterClass: CharacterClass) {
        self.pattern = RegexPattern("\(characterClass.string)*")
    }
}

class Exactly: RegexElement {
    let pattern: RegexPattern
    
    init(_ quantity: Int, _ characterClass: CharacterClass) {
        self.pattern = RegexPattern("\(characterClass.string){\(quantity)}")
    }
}

struct Between: RegexElement {
    let pattern: RegexPattern
    
    init(_ from: Int, and to: Int, _ characterClass: CharacterClass) {
        self.pattern = RegexPattern("\(characterClass.string){\(from),\(to)}")
    }
}

struct Literal: RegexElement {
    let pattern: RegexPattern
    
    init(pattern: RegexPattern) {
        self.pattern = pattern
    }
}

@_functionBuilder
struct NeatRegexBuilder {
    static func buildBlock(_ patterns: RegexElement...) -> RegexElement {
        return Literal(pattern: patterns.map(\.pattern).joined())
    }
}

class NeatRegex {
    let pattern: String
    init(@NeatRegexBuilder _ content: () -> RegexElement) {
        self.pattern = content().pattern
    }
}

