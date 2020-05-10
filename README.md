# RegexBuilder

## Motivation
1. Regular Expression is hard to read

Example: `^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$`

1. Regular Expression is hard to write (maintain)
1. Regular Expression provides several ways to do the same thing

Example: `\d`, `[0-9]`, `\p{Nd}`
1. Regular Expression is error-prone and hard to spot the mistake (because it's a plain string)

Example: You miss a `)`


## Usage
For example, to validate email address instead of:
```
^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$
```

You can write:
``` swift
RegexBuilder()
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
```
