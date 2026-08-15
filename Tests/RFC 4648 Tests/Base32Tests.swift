// Base32Tests.swift
// swift-rfc-4648
//
// Tests for RFC 4648 Section 6: Base32 Encoding

import RFC_4648
import Testing

extension RFC_4648.Base32 {
    @Suite("Base32 Encoding Tests")
    struct Test {
        // MARK: - RFC 4648 Section 10 Test Vectors

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

        // MARK: - Case Insensitivity Tests

        @Test(
            arguments: [
                "MZXW6===",  // uppercase
                "mzxw6===",  // lowercase
                "MzXw6===",  // mixed case
                "mZxW6===",  // random mixed case
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

            // All letters should be uppercase (A-Z)
            for char in encoded {
                if char.isLetter {
                    #expect(char.isUppercase)
                }
            }
        }

        // MARK: - Padding Tests

        @Test(
            arguments: [
                ([Byte]("f".utf8), false, "MY", false),  // no padding
                ([Byte]("f".utf8), true, "MY======", true),  // with padding
                ([Byte]("foo".utf8), false, "MZXW6", false),  // no padding
                ([Byte]("foo".utf8), true, "MZXW6===", true),  // with padding
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

            // Decoding should work both with and without padding
            let decoded = [Byte](base32Encoded: encoded)
            #expect(decoded == input)
        }

        // MARK: - Whitespace Handling

        // Each vector is a single "foobar" payload ("MZXW6YTBOI======") with
        // whitespace inserted between its two quintet groups — not two
        // independently-padded groups concatenated (a padded group must
        // terminate the stream; see the F-001 Edge Case suite below).
        @Test(
            arguments: [
                "MZXW6YTB\nOI======",  // newline
                "MZXW6YTB \tOI======",  // space and tab
                "MZXW6YTB\t\tOI======",  // multiple tabs
                "MZXW6YTB OI======",  // space only
            ]
        )
        func `Base32 whitespace handling`(input: String) {
            let decoded = [Byte](base32Encoded: input)
            #expect(decoded == [Byte]("foobar".utf8), "Whitespace should be ignored in '\(input)'")
        }

        // MARK: - Invalid Input Tests

        @Test(
            arguments: [
                "MZXW0===",  // Base32 doesn't use 0
                "MZXW1===",  // Base32 doesn't use 1
                "MZXW8===",  // Base32 doesn't use 8
                "MZXW9===",  // Base32 doesn't use 9
                "M",  // invalid length (too short)
                "MZXW!@#$",  // special characters
                "========",  // only padding
            ]
        )
        func `Base32 decoding rejects invalid input`(input: String) {
            let decoded = [Byte](base32Encoded: input)
            #expect(decoded == nil, "\(input) should be rejected")
        }

        // MARK: - Alphabet Tests

        @Test
        func `Base32 uses correct alphabet (A-Z, 2-7)`() {
            // Test that all characters in encoding are within A-Z, 2-7 range
            let input: [Byte] = [Byte]("The quick brown fox jumps over the lazy dog".utf8)
            let encoded = String.base32(input, padding: false)

            for char in encoded {
                let isValid = (char >= "A" && char <= "Z") || (char >= "2" && char <= "7")
                #expect(isValid)
            }
        }

        // MARK: - Binary Data Tests

        @Test(
            arguments: [
                ([0x00, 0xFF, 0x80, 0x7F], nil),  // mixed binary
                ([0x00, 0x00, 0x00, 0x00, 0x00], "AAAAAAAA"),  // all zeros
                ([0x00, 0x01, 0x02, 0x03, 0x04], nil),  // sequential bytes
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

        // MARK: - TOTP/HOTP Use Cases

        @Test
        func `Base32 secret key (typical TOTP use)`() {
            // Typical TOTP secret: 20 random bytes
            let secret: [Byte] = [
                0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x21, 0xDE, 0xAD,
                0xBE, 0xEF, 0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x21,
                0xDE, 0xAD, 0xBE, 0xEF,
            ]

            let encoded = String.base32(secret, padding: false)

            // Should be decodable case-insensitively
            let decoded = [Byte](base32Encoded: encoded.lowercased())
            #expect(decoded == secret)
        }

        // MARK: - Edge Cases

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

// MARK: - F-001 Regression Tests

extension RFC_4648.Base32.Test {
    @Suite
    struct `Edge Case` {
        // A short or padded group must be the last thing in the input — the
        // decoder must not silently discard whatever follows it.
        @Test(
            arguments: [
                "MY======X",  // garbage immediately after a padded group
                "MY======MZXQ====",  // a second, independently-padded group after the first
                "MZXW6YTB========",  // trailing all-padding group after a complete group
            ]
        )
        func `rejects input trailing a padded or short group`(input: String) {
            let decoded = [Byte](base32Encoded: input)
            #expect(decoded == nil, "'\(input)' should be rejected, not silently truncated")
        }

        // Quintet remainders of 1, 3, or 6 never land on a whole-byte
        // boundary and can never appear as a properly-padded group.
        @Test(
            arguments: [
                "M",  // 1 quintet, unpadded
                "MZX",  // 3 quintets, unpadded
                "MZXW6Y",  // 6 quintets, unpadded
            ]
        )
        func `rejects quintet remainders that never land on a byte boundary`(input: String) {
            let decoded = [Byte](base32Encoded: input)
            #expect(decoded == nil, "'\(input)' has an invalid quintet remainder")
        }
    }
}

// MARK: - F-004 Regression Tests (opt-in strictness)

extension RFC_4648.Base32.Test.`Edge Case` {
    @Test
    func `strict strictness rejects whitespace that lenient accepts`() {
        #expect(RFC_4648.Base32.decode("MZXW6YTB OI======", strictness: .lenient) != nil)
        #expect(RFC_4648.Base32.decode("MZXW6YTB OI======", strictness: .strict) == nil)
    }

    @Test
    func `strict strictness rejects nonzero trailing padding bits`() {
        // "AB======": quintets A(0), B(1) — the low 2 bits of B's quintet
        // don't map onto the single decoded byte and are nonzero.
        #expect(RFC_4648.Base32.decode("AB======", strictness: .lenient) == [0x00])
        #expect(RFC_4648.Base32.decode("AB======", strictness: .strict) == nil)

        // "AA======" is the canonical encoding of the same byte.
        #expect(RFC_4648.Base32.decode("AA======", strictness: .strict) == [0x00])
    }
}

// MARK: - F-003 Regression Tests (decode(as:) octet semantics)

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
        let encoded = String.base32(UInt32(123_456))  // 4 bytes
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
