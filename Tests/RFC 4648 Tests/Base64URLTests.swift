import RFC_4648
import Testing

extension RFC_4648.Base64.URL {
    @Suite("Base64URL Encoding Tests")
    struct Test {

        @Test(
            arguments: [
                ([], ""),
                ([Byte]("hello".utf8), nil),
            ]
        )
        func `Base64URL basic patterns`(input: [Byte], expectedEncoded: String?) {
            let encoded = String.base64.url(input)

            if let expected = expectedEncoded {
                #expect(encoded == expected)
            }

            let decoded = [Byte](base64URLEncoded: encoded)
            #expect(decoded == input)
        }

        @Test
        func `Base64URL uses URL-safe characters`() {

            let input: [Byte] = [0xFB, 0xFF, 0xFF]
            let encoded = String.base64.url(input)

            #expect(encoded.contains("-") || encoded.contains("_"))
            #expect(!encoded.contains("+"))
            #expect(!encoded.contains("/"))

            let decoded = [Byte](base64URLEncoded: encoded)
            #expect(decoded == input)
        }

        @Test
        func `Base64URL with special chars`() {

            let input: [Byte] = [0xFF, 0xFF]
            let encoded = String.base64.url(input)

            #expect(encoded.contains("_"))
            #expect(!encoded.contains("/"))
        }

        @Test(
            arguments: [
                ([Byte]("f".utf8), false, "Zg", false),
                ([Byte]("f".utf8), true, "Zg==", true),
                ([Byte]("fo".utf8), false, "Zm8", false),
                ([Byte]("fo".utf8), true, "Zm8=", true),
                ([Byte]("foo".utf8), false, "Zm9v", false),
            ]
        )
        func `Base64URL padding variations`(
            input: [Byte],
            padding: Bool,
            expectedEncoded: String,
            shouldHavePadding: Bool
        ) {
            let encoded = String.base64.url(input, padding: padding)
            #expect(encoded == expectedEncoded)
            #expect(encoded.contains("=") == shouldHavePadding)

            let decoded = [Byte](base64URLEncoded: encoded)
            #expect(decoded == input)
        }

        @Test
        func `Base64URL decoding with whitespace`() {
            let input = "Zm9v\nYmFy"
            let decoded = [Byte](base64URLEncoded: input)
            #expect(decoded == [Byte]("foobar".utf8))
        }

        @Test(
            arguments: [
                "Zg+A",
                "Zg/A",
                "Zm9v!!!!",
                "Z",
            ]
        )
        func `Base64URL decoding rejects invalid input`(input: String) {
            let decoded = [Byte](base64URLEncoded: input)
            #expect(decoded == nil, "\(input) should be rejected")
        }

        @Test
        func `Base64URL JWT header example`() {

            let headerJSON = [Byte]("{\"alg\":\"HS256\",\"typ\":\"JWT\"}".utf8)
            let encoded = String.base64.url(headerJSON, padding: false)

            #expect(!encoded.contains("+"))
            #expect(!encoded.contains("/"))
            #expect(!encoded.contains("="))

            let decoded = [Byte](base64URLEncoded: encoded)
            #expect(decoded == headerJSON)
        }

        @Test
        func `Base64URL binary data`() {
            let input: [Byte] = [0x00, 0xFF, 0x80, 0x7F, 0x3E, 0x3F]
            let encoded = String.base64.url(input)
            let decoded = [Byte](base64URLEncoded: encoded)
            #expect(decoded == input)
        }

        @Test
        func `Base64URL all special characters`() {

            let input: [Byte] = [0xFF, 0xEF, 0xFF, 0xEF]
            let encoded = String.base64.url(input)

            if encoded.contains("_") {
                #expect(!encoded.contains("/"))
            }
            if encoded.contains("-") {
                #expect(!encoded.contains("+"))
            }

            let decoded = [Byte](base64URLEncoded: encoded)
            #expect(decoded == input)
        }

        @Test
        func `Base64URL round-trip long string`() {
            let longString = String(repeating: "Hello, World! ", count: 100)
            let input = [Byte](longString.utf8)
            let encoded = String.base64.url(input, padding: false)
            let decoded = [Byte](base64URLEncoded: encoded)
            #expect(decoded == input)
        }

        @Test
        func `Base64URL produces different output than Base64 for special chars`() {
            let input: [Byte] = [0xFF, 0xFF]

            let base64 = String.base64(input, padding: true)
            let base64url = String.base64.url(input, padding: false)

            #expect(base64 != base64url)

            #expect([Byte](base64Encoded: base64) == input)
            #expect([Byte](base64URLEncoded: base64url) == input)
        }
    }
}

extension RFC_4648.Base64.URL.Test {
    @Suite
    struct `Edge Case` {
        @Test
        func `decode(as:) matches octet semantics of the FixedWidthInteger init family`() throws {
            let value = UInt32(123_456)
            let encoded = String.base64.url(value)
            let codes = try [ASCII.Code](encoded.utf8)

            #expect(RFC_4648.Base64.URL.decode(codes, as: UInt32.self) == value)
            #expect(
                RFC_4648.Base64.URL.decode(codes, as: UInt32.self)
                    == UInt32(base64URLEncoded: encoded)
            )
        }

        @Test
        func `decode(as:) rejects a byte count that does not match the target width`() throws {
            let encoded = String.base64.url(UInt32(123_456))
            let codes = try [ASCII.Code](encoded.utf8)
            #expect(RFC_4648.Base64.URL.decode(codes, as: UInt8.self) == nil)
            #expect(RFC_4648.Base64.URL.decode(codes, as: UInt64.self) == nil)
        }

        @Test
        func `decode(as:) on empty input returns nil like the FixedWidthInteger init family`() {
            let value: UInt32? = RFC_4648.Base64.URL.decode([ASCII.Code]())
            #expect(value == nil)
            #expect(value == UInt32(base64URLEncoded: ""))
        }
    }
}
