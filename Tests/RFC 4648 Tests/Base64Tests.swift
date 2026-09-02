import RFC_4648
import Testing

extension RFC_4648.Base64 {
    @Suite("Base64 Encoding Tests")
    struct Test {

        @Test(
            arguments: [
                ("", ""),
                ("f", "Zg=="),
                ("fo", "Zm8="),
                ("foo", "Zm9v"),
                ("foob", "Zm9vYg=="),
                ("fooba", "Zm9vYmE="),
                ("foobar", "Zm9vYmFy"),
            ]
        )
        func `RFC 4648 test vectors`(input: String, expected: String) {
            let bytes = input.utf8.map(Byte.init(bitPattern:))
            let encoded = String.base64(bytes)
            #expect(encoded == expected, "Encoding '\(input)' should produce '\(expected)'")

            let decoded = [Byte](base64Encoded: encoded)
            #expect(decoded == bytes, "Round-trip failed for '\(input)'")
        }

        @Test(
            arguments: [
                ("f".utf8.map(Byte.init(bitPattern:)), false, "Zg", [Byte]?.none),
                ("f".utf8.map(Byte.init(bitPattern:)), true, "Zg==", "f".utf8.map(Byte.init(bitPattern:))),
                ("fo".utf8.map(Byte.init(bitPattern:)), false, "Zm8", [Byte]?.none),
                ("fo".utf8.map(Byte.init(bitPattern:)), true, "Zm8=", "fo".utf8.map(Byte.init(bitPattern:))),
                ("foo".utf8.map(Byte.init(bitPattern:)), false, "Zm9v", "foo".utf8.map(Byte.init(bitPattern:))),

            ]
        )
        func `Base64 padding variations`(
            input: [Byte],
            padding: Bool,
            expectedEncoded: String,
            expectedDecoded: [Byte]?
        ) {
            let encoded = String.base64(input, padding: padding)
            #expect(encoded == expectedEncoded)

            let decoded = [Byte](base64Encoded: encoded)
            #expect(decoded == expectedDecoded)
        }

        @Test(
            arguments: [
                "Zm9v\nYmFy",
                "Zm9v\tYmFy",
                "Zm9v YmFy",
                "Zm9v\n\t YmFy",
            ]
        )
        func `Base64 decoding with whitespace`(input: String) {
            let decoded = [Byte](base64Encoded: input)
            #expect(decoded == "foobar".utf8.map(Byte.init(bitPattern:)), "Whitespace should be ignored")
        }

        @Test(
            arguments: [
                "Zm9v!!!!",
                "Zm9",
                "====",
                "Z",
            ]
        )
        func `Base64 decoding rejects invalid input`(input: String) {
            let decoded = [Byte](base64Encoded: input)
            #expect(decoded == nil, "\(input) should be rejected")
        }

        @Test(
            arguments: [
                (([0x00, 0xFF, 0x80, 0x7F] as [UInt8]).map(Byte.init(bitPattern:)), nil),
                (([0x00, 0x00, 0x00] as [UInt8]).map(Byte.init(bitPattern:)), "AAAA"),
                (([0xFF, 0xFF, 0xFF] as [UInt8]).map(Byte.init(bitPattern:)), "////"),
            ]
        )
        func `Base64 binary data patterns`(input: [Byte], expectedEncoded: String?) {
            let encoded = String.base64(input)

            if let expected = expectedEncoded {
                #expect(encoded == expected)
            }

            let decoded = [Byte](base64Encoded: encoded)
            #expect(decoded == input)
        }

        @Test
        func `Base64 round-trip long string`() {
            let longString = String(repeating: "Hello, World! ", count: 100)
            let input = longString.utf8.map(Byte.init(bitPattern:))
            let encoded = String.base64(input)
            let decoded = [Byte](base64Encoded: encoded)
            #expect(decoded == input)
        }
    }
}

extension RFC_4648.Base64.Test {
    @Suite
    struct `Edge Case` {

        @Test(
            arguments: [
                "Zg==X",
                "Zg==Zm8=",
                "AAAA====",
                "MY=X",
            ]
        )
        func `rejects input trailing a padded or short group`(input: String) {
            let decoded = [Byte](base64Encoded: input)
            #expect(decoded == nil, "'\(input)' should be rejected, not silently truncated")
        }

        @Test
        func `whitespace decoding produces the exact expected bytes`() {
            #expect([Byte](base64Encoded: "Zm9v\nYmFy") == "foobar".utf8.map(Byte.init(bitPattern:)))
            #expect([Byte](base64Encoded: "Zm9v YmFy") == "foobar".utf8.map(Byte.init(bitPattern:)))
        }
    }
}

extension RFC_4648.Base64.Test.`Edge Case` {
    @Test
    func `lenient strictness is the default and matches unqualified decode`() {
        #expect(
            RFC_4648.Base64.decode("Zm9v YmFy")
                == RFC_4648.Base64.decode("Zm9v YmFy", strictness: .lenient)
        )
    }

    @Test
    func `strict strictness rejects whitespace that lenient accepts`() {
        #expect(RFC_4648.Base64.decode("Zm9v YmFy", strictness: .lenient) != nil)
        #expect(RFC_4648.Base64.decode("Zm9v YmFy", strictness: .strict) == nil)
    }

    @Test
    func `strict strictness rejects nonzero trailing padding bits`() {

        #expect(RFC_4648.Base64.decode("AB==", strictness: .lenient) == ([0x00] as [UInt8]).map(Byte.init(bitPattern:)))
        #expect(RFC_4648.Base64.decode("AB==", strictness: .strict) == nil)

        #expect(RFC_4648.Base64.decode("AA==", strictness: .strict) == ([0x00] as [UInt8]).map(Byte.init(bitPattern:)))
    }
}

extension RFC_4648.Base64.Test.`Edge Case` {
    @Test
    func `decode(as:) matches the documented doc-example value`() throws {

        let value: UInt32? = RFC_4648.Base64.decode(try "AQIDBA==".utf8.map { try ASCII.Code(Byte(bitPattern: $0)) })
        #expect(value == 0x0102_0304)
    }

    @Test
    func `decode(as:) matches octet semantics of the FixedWidthInteger init family`() throws {
        let value = UInt32(123_456)
        let encoded = String.base64(value)
        let codes = try encoded.utf8.map { try ASCII.Code(Byte(bitPattern: $0)) }

        #expect(RFC_4648.Base64.decode(codes, as: UInt32.self) == value)
        #expect(RFC_4648.Base64.decode(codes, as: UInt32.self) == UInt32(base64Encoded: encoded))
    }

    @Test
    func `decode(as:) rejects a byte count that does not match the target width`() throws {
        let encoded = String.base64(UInt32(123_456))
        let codes = try encoded.utf8.map { try ASCII.Code(Byte(bitPattern: $0)) }
        #expect(RFC_4648.Base64.decode(codes, as: UInt8.self) == nil)
        #expect(RFC_4648.Base64.decode(codes, as: UInt64.self) == nil)
    }

    @Test
    func `decode(as:) on empty input returns nil like the FixedWidthInteger init family`() {

        let value: UInt32? = RFC_4648.Base64.decode([ASCII.Code]())
        #expect(value == nil)
        #expect(value == UInt32(base64Encoded: ""))
    }
}
