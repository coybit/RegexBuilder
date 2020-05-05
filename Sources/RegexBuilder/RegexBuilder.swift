import Foundation

class RegexBuilder {
    private(set) var regex: String = ""
    
    func digit(_ quantity: Quantity, of type: Digit) -> Self {
        switch type {
        case .zeroToNine:
            regex.append("\\d")
        case .just(let digits):
            regex.append("[\(digits.map(String.init).joined())]")
        }
        
        regex.append(quantity.representation)
        return self
    }
    
    func character(_ quantity: Quantity, of types: [Character]) -> Self {
        
        let combined = Array<Character>(Set<Character>(types))
            .map { $0.rawValue }
            .sorted()
            .joined()
        
        if combined == "\\p{Ll}\\p{Lo}\\p{Lu}\\p{Nd}" {
            regex.append("\\w")
        } else if types.count > 1 {
            regex.append("[\(combined)]")
        } else {
            regex.append(combined)
        }

        regex.append(quantity.representation)
        return self
    }
    
    func space(_ quantity: Quantity, of types: [Spaces]) -> Self {
        let combined = types
            .map { $0.rawValue }
            .sorted()
            .joined()
        
        if combined == "\\f\\n\\p{Z}\\r\\t" {
            regex.append("\\s")
        } else if types.count > 1 {
            regex.append("[\(combined)]")
        } else {
            regex.append(combined)
        }
        
        regex.append(quantity.representation)
        return self
    }
    
    func either(_ a: RegexBuilder, _ b: RegexBuilder) -> Self {
        regex.append(a.regex)
        regex.append("|")
        regex.append(b.regex)
        return self
    }
    
    func beginning(of relativeTo: Anchor) -> Self {
        switch relativeTo {
        case .line: regex.append("^")
        }
        return self
    }
    
    func end(of relativeTo: Anchor) -> Self {
        switch relativeTo {
        case .line: regex.append("$")
        }
        return self
    }
    
    func not(_ a: RegexBuilder) -> Self {
        regex.append("[^\(a.regex)]")
        return self
    }
    
    enum Anchor {
        case line
    }
    
    enum Digit {
        case zeroToNine
        case just([Int])
    }
    
    enum Spaces: String {
        case space = "\\p{Z}"
        case tab = "\\t"
        case newline = "\\n"
        case carriageReturn = "\\r"
        case formFeed = "\\f"
    }
    
    enum Character: RawRepresentable, Hashable {
        case digit
        case underscore
        case dash
        case lowerCaseAscii
        case upperCaseAscii
        case ideograph
        case dot
        case literal(Swift.Character)
        
        init?(rawValue: String) {
            return nil
        }
        
        var rawValue: String {
            switch self {
            case .digit: return "\\p{Nd}"
            case .underscore: return "_"
            case .dash: return "\\-"
            case .lowerCaseAscii: return "\\p{Ll}"
            case .upperCaseAscii: return "\\p{Lu}"
            case .ideograph: return "\\p{Lo}"
            case .dot: return "\\."
            case .literal(let c): return String(c)
            }
        }
    }
    
    enum Quantity {
        case oneOrMore
        case zeroOrMore
        case exactly(Int)
        case between(Int, Int)
        case atLeast(Int)
        case atMostOne
        
        var representation: String {
            switch self {
            case .oneOrMore: return "+"
            case .zeroOrMore: return "*"
            case .exactly(let num): return "{\(num)}"
            case .between(let a, let b): return "{\(a),\(b)}"
            case .atLeast(let a): return "{\(a),}"
            case .atMostOne: return "?"
            }
        }
    }
}
