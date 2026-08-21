import RFC_4648
import Testing

extension RFC_4648.Base32 {
    @Suite("Base32 Encoding Tests")
    struct Test {

        @Test(
            arguments: [
                ("", ""),
                ("f", "MY======"),
                ("fo", "MZXQ===="),
                ("foo", "MZXW6==="),
                ("foob", "MZXW6YQ="),
                ("fooba", "MZXW6YTB"),
                ("foobar", "MZXW6YTBOI======"),
            ]
        )
        func `RFC 4648 test vectors`(input: String, expected: String) {
            let bytes = [Byte](input.utf8)
            let encoded = String.base32(bytes)
            #expect(encoded == expected, "Encoding '\(input)' should produce '\(expected)'")

            let decoded = [Byte](base32Encoded: encoded)
            #expect(decoded == bytes, "Round-trip failed for '\(input)'")
        }

        @Test(
            arguments: [
                "MZXW6===",
                "mzxw6===",
                "MzXw6===",
                "mZxW6===",
            ]
        )
        func `Base32 decoding is case-insensitive`(encoded: String) {
            let expected: [Byte] = [Byte]("foo".utf8)
            let decoded = [Byte](base32Encoded: encoded)
            #expect(decoded == expected, "Case-insensitive decoding should work for '\(encoded)'")
        }

        @Test
        func `Base32 encoding produces uppercase`() {
            let input: [Byte] = [Byte]("hello".utf8)
            let encoded = String.base32(input)

            for char in encoded {
                if char.isLetter {
                    #expect(char.isUppercase)
                }
            }
        }

        @Test(
            arguments: [
                ([Byte]("f".utf8), false, "MY", false),
                ([Byte]("f".utf8), true, "MY======", true),
                ([Byte]("foo".utf8), false, "MZXW6", false),
                ([Byte]("foo".utf8), true, "MZXW6===", true),
            ]
        )
        func `Base32 padding variations`(
            input: [Byte],
            padding: Bool,
            expectedEncoded: String,
            shouldHavePadding: Bool
        ) {
            let encoded = String.base32(input, padding: padding)
            #expect(encoded == expectedEncoded)
            #expect(encoded.contains("=") == shouldHavePadding)

            let decoded = [Byte](base32Encoded: encoded)
            #expect(decoded == input)
        }

        @Test(
            arguments: [
                "MZXW6YTB\nOI======",
                "MZXW6YTB \tOI======",
                "MZXW6YTB\t\tOI======",
                "MZXW6YTB OI======",
            ]
        )
        func `Base32 whitespace handling`(input: String) {
            let decoded = [Byte](base32Encoded: input)
            #expect(decoded == [Byte]("foobar".utf8), "Whitespace should be ignored in '\(input)'")
        }

        @Test(
            arguments: [
                "MZXW0===",
                "MZXW1===",
                "MZXW8===",
                "MZXW9===",
                "M",
                "MZXW!@#$",
                "========",
            ]
        )
        func `Base32 decoding rejects invalid input`(input: String) {
            let decoded = [Byte](base32Encoded: input)
            #expect(decoded == nil, "\(input) should be rejected")
        }

        @Test
        func `Base32 uses correct alphabet (A-Z, 2-7)`() {

            let input: [Byte] = [Byte]("The quick brown fox jumps over the lazy dog".utf8)
            let encoded = String.base32(input, padding: false)

            for char in encoded {
                let isValid = (char >= "A" && char <= "Z") || (char >= "2" && char <= "7")
                #expect(isValid)
            }
        }

        @Test(
            arguments: [
                ([0x00, 0xFF, 0x80, 0x7F], nil),
                ([0x00, 0x00, 0x00, 0x00, 0x00], "AAAAAAAA"),
                ([0x00, 0x01, 0x02, 0x03, 0x04], nil),
            ]
        )
        func `Base32 binary data patterns`(input: [Byte], expectedEncoded: String?) {
            let encoded = String.base32(input)

            if let expected = expectedEncoded {
                #expect(encoded == expected)
            }

            let decoded = [Byte](base32Encoded: encoded)
            #expect(decoded == input)
        }

        @Test
        func `Base32 secret key (typical TOTP use)`() {

            let secret: [Byte] = [
                0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x21, 0xDE, 0xAD,
                0xBE, 0xEF, 0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x21,
                0xDE, 0xAD, 0xBE, 0xEF,
            ]

            let encoded = String.base32(secret, padding: false)

            let decoded = [Byte](base32Encoded: encoded.lowercased())
            #expect(decoded == secret)
        }

        @Test
        func `Base32 round-trip various sizes`() {
            for size in [1, 2, 3, 4, 5, 10, 20, 50, 100] {
                let input: [Byte] = (0..<size).map { Byte(UInt8($0 % 256)) }
                let encoded = String.base32(input)
                let decoded = [Byte](base32Encoded: encoded)
                #expect(decoded == input)
            }
        }

        @Test
        func `Base32 round-trip long string`() {
            let longString = String(repeating: "Hello, World! ", count: 100)
            let input = [Byte](longString.utf8)
            let encoded = String.base32(input)
            let decoded = [Byte](base32Encoded: encoded)
            #expect(decoded == input)
        }
    }
}

extension RFC_4648.Base32.Test {
    @Suite
    struct `Edge Case` {

        @Test(
            arguments: [
                "MY======X",
                "MY======MZXQ====",
                "MZXW6YTB========",
            ]
        )
        func `rejects input trailing a padded or short group`(input: String) {
            let decoded = [Byte](base32Encoded: input)
            #expect(decoded == nil, "'\(input)' should be rejected, not silently truncated")
        }

        @Test(
            arguments: [
                "M",
                "MZX",
                "MZXW6Y",
            ]
        )
        func `rejects quintet remainders that never land on a byte boundary`(input: String) {
            let decoded = [Byte](base32Encoded: input)
            #expect(decoded == nil, "'\(input)' has an invalid quintet remainder")
        }
    }
}

extension RFC_4648.Base32.Test.`Edge Case` {
    @Test
    func `strict strictness rejects whitespace that lenient accepts`() {
        #expect(RFC_4648.Base32.decode("MZXW6YTB OI======", strictness: .lenient) != nil)
        #expect(RFC_4648.Base32.decode("MZXW6YTB OI======", strictness: .strict) == nil)
    }

    @Test
    func `strict strictness rejects nonzero trailing padding bits`() {

        #expect(RFC_4648.Base32.decode("AB======", strictness: .lenient) == [0x00])
        #expect(RFC_4648.Base32.decode("AB======", strictness: .strict) == nil)

        #expect(RFC_4648.Base32.decode("AA======", strictness: .strict) == [0x00])
    }
}

extension RFC_4648.Base32.Test.`Edge Case` {
    @Test
    func `decode(as:) matches octet semantics of the FixedWidthInteger init family`() throws {
        let value = UInt32(123_456)
        let encoded = String.base32(value)
        let codes = try [ASCII.Code](encoded.utf8)

        #expect(RFC_4648.Base32.decode(codes, as: UInt32.self) == value)
        #expect(RFC_4648.Base32.decode(codes, as: UInt32.self) == UInt32(base32Encoded: encoded))
    }

    @Test
    func `decode(as:) rejects a byte count that does not match the target width`() throws {
        let encoded = String.base32(UInt32(123_456))
        let codes = try [ASCII.Code](encoded.utf8)
        #expect(RFC_4648.Base32.decode(codes, as: UInt8.self) == nil)
        #expect(RFC_4648.Base32.decode(codes, as: UInt64.self) == nil)
    }

    @Test
    func `decode(as:) on empty input returns nil like the FixedWidthInteger init family`() {
        let value: UInt32? = RFC_4648.Base32.decode([ASCII.Code]())
        #expect(value == nil)
        #expect(value == UInt32(base32Encoded: ""))
    }
}
