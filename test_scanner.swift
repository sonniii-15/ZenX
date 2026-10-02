import Foundation
let scanner = Scanner(string: "5ac938489f039d35fdafa3")
var value: UInt64 = 0
let success = scanner.scanHexInt64(&value)
print("Success: \(success), isAtEnd: \(scanner.isAtEnd), value: \(value)")
