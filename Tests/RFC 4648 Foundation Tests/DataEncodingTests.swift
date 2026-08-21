import Foundation
import Testing

@testable import RFC_4648_Foundation

extension Data {
    @Suite("Data Encoding Tests")
    struct Test {

        @Test
        func `Data Base64URL encoding`() {
            let data = Data("foobar".utf8)

            #expect(data.base64URLEncodedString() == "Zm9vYmFy")
            #expect(data.base64URLEncodedString(padding: false) == "Zm9vYmFy")
            #expect(data.base64URLEncodedString(padding: true) == "Zm9vYmFy")
        }

        @Test
        func `Data Base64URL decoding`() {
            let encoded = "Zm9vYmFy"
            let data = Data(base64URLEncoded: encoded)

            #expect(data != nil)
            #expect(String(data: data!, encoding: .utf8) == "foobar")
        }

        @Test
        func `Data Base64URL handles URL-safe characters`() {

            let data = Data([0xFF, 0xFF, 0xFF])

            let base64URL = data.base64URLEncodedString()

            #expect(!base64URL.contains("+"))
            #expect(!base64URL.contains("/"))

            let decoded = Data(base64URLEncoded: base64URL)
            #expect(decoded == data)
        }

        @Test
        func `Data Base32 encoding`() {
            let data = Data("foo".utf8)

            #expect(data.base32EncodedString() == "MZXW6===")
            #expect(data.base32EncodedString(padding: false) == "MZXW6")
        }

        @Test
        func `Data Base32 decoding`() {
            let encoded = "MZXW6==="
            let data = Data(base32Encoded: encoded)

            #expect(data != nil)
            #expect(String(data: data!, encoding: .utf8) == "foo")
        }

        @Test
        func `Data Base32 case insensitive decoding`() {
            let upper = Data(base32Encoded: "MZXW6===")
            let lower = Data(base32Encoded: "mzxw6===")
            let mixed = Data(base32Encoded: "MzXw6===")

            #expect(upper == lower)
            #expect(lower == mixed)
            #expect(String(data: upper!, encoding: .utf8) == "foo")
        }

        @Test
        func `Data Base32-HEX encoding`() {
            let data = Data("foo".utf8)

            #expect(data.base32HexEncodedString() == "CPNMU===")
            #expect(data.base32HexEncodedString(padding: false) == "CPNMU")
        }

        @Test
        func `Data Base32-HEX decoding`() {
            let encoded = "CPNMU==="
            let data = Data(base32HexEncoded: encoded)

            #expect(data != nil)
            #expect(String(data: data!, encoding: .utf8) == "foo")
        }

        @Test
        func `Data Base32-HEX differs from Base32`() {
            let data = Data("foo".utf8)

            let base32 = data.base32EncodedString()
            let base32Hex = data.base32HexEncodedString()

            #expect(base32 != base32Hex)

            #expect(Data(base32Encoded: base32) == data)
            #expect(Data(base32HexEncoded: base32Hex) == data)
        }

        @Test
        func `Data hexadecimal encoding`() {
            let data = Data([0xDE, 0xAD, 0xBE, 0xEF])

            #expect(data.hexEncodedString() == "deadbeef")
            #expect(data.hexEncodedString(uppercase: false) == "deadbeef")
            #expect(data.hexEncodedString(uppercase: true) == "DEADBEEF")
        }

        @Test
        func `Data hexadecimal decoding`() {
            let lower = Data(hexEncoded: "deadbeef")
            let upper = Data(hexEncoded: "DEADBEEF")
            let mixed = Data(hexEncoded: "DeAdBeEf")

            #expect(lower == upper)
            #expect(upper == mixed)
            #expect(lower == Data([0xDE, 0xAD, 0xBE, 0xEF]))
        }

        @Test(
            arguments: [
                Data([0x00]),
                Data([0xFF]),
                Data([0x00, 0x0F, 0xFF]),
                Data([0xDE, 0xAD, 0xBE, 0xEF]),
                Data((0...255).map { UInt8($0) }),
            ]
        )
        func `Data hexadecimal round-trip`(input: Data) {
            let encoded = input.hexEncodedString()
            let decoded = Data(hexEncoded: encoded)

            #expect(decoded == input)
        }

        @Test(
            arguments: [
                "base64URL", "base32", "base32Hex", "hex",
            ]
        )
        func `Empty data encoding`(encoding: String) {
            let empty = Data()

            switch encoding {
            case "base64URL":
                #expect(empty.base64URLEncodedString().isEmpty)

            case "base32":
                #expect(empty.base32EncodedString().isEmpty)

            case "base32Hex":
                #expect(empty.base32HexEncodedString().isEmpty)

            case "hex":
                #expect(empty.hexEncodedString().isEmpty)

            default:
                break
            }
        }

        @Test(
            arguments: [
                "base64URL", "base32", "base32Hex", "hex",
            ]
        )
        func `Empty string decoding`(encoding: String) {
            let empty = ""

            switch encoding {
            case "base64URL":
                #expect(Data(base64URLEncoded: empty) == Data())

            case "base32":
                #expect(Data(base32Encoded: empty) == Data())

            case "base32Hex":
                #expect(Data(base32HexEncoded: empty) == Data())

            case "hex":
                #expect(Data(hexEncoded: empty) == Data())

            default:
                break
            }
        }

        @Test
        func `Invalid Base32 decoding`() {
            #expect(Data(base32Encoded: "189") == nil)
        }

        @Test
        func `Invalid hexadecimal decoding`() {
            #expect(Data(hexEncoded: "GHIJK") == nil)
            #expect(Data(hexEncoded: "fff") == nil)
        }

        @Test
        func `Large data encoding and decoding`() {
            let largeData = Data((0..<10000).map { UInt8($0 % 256) })

            let base64url = largeData.base64URLEncodedString()
            #expect(Data(base64URLEncoded: base64url) == largeData)

            let hex = largeData.hexEncodedString()
            #expect(Data(hexEncoded: hex) == largeData)
        }
    }
}
