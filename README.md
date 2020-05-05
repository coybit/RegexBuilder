# RegexBuilder
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
