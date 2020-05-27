# RegexBuilder

## Motivation
1. Regular Expression is hard to read

Example: `^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$`

2. Regular Expression is hard to write (maintain)
3. Regular Expression provides several ways to do the same thing

Example: `\d`, `[0-9]`, `\p{Nd}`

4. Regular Expression is error-prone and hard to spot the mistake (because it's a plain string)

Example: You miss a `)`


## Example
Assume we want to extract two pieces of information (zip code and phone) from a string. 
The left image is the piece of code we usually end up with. 
The right image is the code that does the same but it more readable:
<img src="https://github.com/coybit/RegexBuilder/raw/master/Images/comparison.jpg">
