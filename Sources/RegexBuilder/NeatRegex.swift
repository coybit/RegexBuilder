import Foundation

typealias RegexPattern = String

protocol RegexElement {
    var pattern: RegexPattern { get }
}

protocol StorableRegexElement: RegexElement {
    associatedtype Store
    var path: WritableKeyPath<Store, String?> { get }
}

enum PatternAnchor {
    case line
}

enum CharacterClass {
    case digit
    case space
    case alphabet
    case digitOrAlphabet
    case literal(Character)
    
    var string: String {
        switch self {
        case .digit: return #"\d"#
        case .space: return #"\s"#
        case .alphabet: return #"\w"#
        case .digitOrAlphabet: return #"[0-9a-zA-Z]"#
        case .literal(let c): return "\\\(c)"
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
        self.pattern = RegexPattern("\(characterClass.string)*")
    }
}

struct OneOrMore: RegexElement {
    let pattern: RegexPattern
    
    init(_ characterClass: CharacterClass) {
        self.pattern = RegexPattern("\(characterClass.string)+")
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

struct Extract<S>: StorableRegexElement {
    typealias Store = S
    
    let pattern: RegexPattern
    let path: WritableKeyPath<S, String?>
    
    init(storeAt path: WritableKeyPath<S, String?>, @NeatRegexBuilder<S> _ content: () -> RegexElement) {
        self .path = path
        self.pattern = "(\(content().pattern))"
    }
}

struct Literal<S>: RegexElement {
    typealias Store = S
    
    let pattern: RegexPattern
    let paths: [WritableKeyPath<S, String?>]
    
    init(pattern: RegexPattern, paths: [WritableKeyPath<S, String?>]) {
        self.pattern = pattern
        self.paths = paths
    }
}

@_functionBuilder
struct NeatRegexBuilder<S> {
    static func buildBlock(_ patterns: RegexElement...) -> RegexElement {
        return Literal<S>(
            pattern: patterns.map(\.pattern).joined(),
            paths: patterns.compactMap { $0 as? Extract<S> }.map(\.path)
            )
    }
}

class NeatRegex<S> {
    init?(on text: String, store: inout S, @NeatRegexBuilder<S> _ content: () -> RegexElement) {
        guard let literal = content() as? Literal<S> else { return nil }
        
        let pattern = literal.pattern
        let paths = literal.paths
        
        let re = try! NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
        let matches = re.matches(in: text, options: [], range: NSRange(location: 0, length: text.count))
        
        for i in 0..<matches.count {
            guard re.numberOfCaptureGroups > 0 else { continue }
            for j in 1...re.numberOfCaptureGroups {
                let range = matches[i].range(at: j)
                
                if range.location == NSNotFound { continue }
                
                if let swiftRange = Range(range, in: text) {
                    let value = text[swiftRange]
                    store[keyPath: paths[j-1]] = String(value)
                }
            }
        }
    }
}

