// Base64Tests.swift
// swift-rfc-4648
//
// Tests for RFC 4648 Section 4: Base64 Encoding

import RFC_4648
import Testing

extension RFC_4648.Base64 {
    @Suite("Base64 Encoding Tests")
    struct Test {
        // MARK: - RFC 4648 Section 10 Test Vectors

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
            let bytes = [Byte](input.utf8)
            let encoded = String.base64(bytes)
            #expect(encoded == expected, "Encoding '\(input)' should produce '\(expected)'")

            let decoded = [Byte](base64Encoded: encoded)
            #expect(decoded == bytes, "Round-trip failed for '\(input)'")
        }

        // MARK: - Padding Tests

        @Test(
            arguments: [
                ([Byte]("f".utf8), false, "Zg", [Byte]?.none),  // no padding - decoding fails
                ([Byte]("f".utf8), true, "Zg==", [Byte]("f".utf8)),  // with padding - succeeds
                ([Byte]("fo".utf8), false, "Zm8", [Byte]?.none),  // no padding - fails
                ([Byte]("fo".utf8), true, "Zm8=", [Byte]("fo".utf8)),  // with padding - succeeds
                ([Byte]("foo".utf8), false, "Zm9v", [Byte]("foo".utf8)),  // no padding needed
                //            ([Byte]("foo".utf8), true, "Zm9v", [Byte]("foo".utf8)),  // padding doesn't hurt
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

        // MARK: - Whitespace Handling

        @Test(
            arguments: [
                "Zm9v\nYmFy",  // newline
                "Zm9v\tYmFy",  // tab
                "Zm9v YmFy",  // space
                "Zm9v\n\t YmFy",  // mixed whitespace
            ]
        )
        func `Base64 decoding with whitespace`(input: String) {
            let decoded = [Byte](base64Encoded: input)
            #expect(decoded == [Byte]("foobar".utf8), "Whitespace should be ignored")
        }

        // MARK: - Invalid Input Tests

        @Test(
            arguments: [
                "Zm9v!!!!",  // invalid characters
                "Zm9",  // invalid length (not multiple of 4)
                "====",  // only padding
                "Z",  // too short
            ]
        )
        func `Base64 decoding rejects invalid input`(input: String) {
            let decoded = [Byte](base64Encoded: input)
            #expect(decoded == nil, "\(input) should be rejected")
        }

        // MARK: - Binary Data Tests

        @Test(
            arguments: [
                ([0x00, 0xFF, 0x80, 0x7F], nil),  // mixed binary data
                ([0x00, 0x00, 0x00], "AAAA"),  // all zeros
                ([0xFF, 0xFF, 0xFF], "////"),  // all ones
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

        // MARK: - Edge Cases

        @Test
        func `Base64 round-trip long string`() {
            let longString = String(repeating: "Hello, World! ", count: 100)
            let input = [Byte](longString.utf8)
            let encoded = String.base64(input)
            let decoded = [Byte](base64Encoded: encoded)
            #expect(decoded == input)
        }
    }
}

// MARK: - F-001 Regression Tests

extension RFC_4648.Base64.Test {
    @Suite
    struct `Edge Case` {
        // A short or padded group must be the last thing in the input — the
        // decoder must not silently discard whatever follows it.
        @Test(
            arguments: [
                "Zg==X",  // garbage immediately after a padded group
                "Zg==Zm8=",  // a second, independently-padded group after the first
                "AAAA====",  // trailing all-padding group after a complete group
                "MY=X",  // non-whitespace character mid-padding
            ]
        )
        func `rejects input trailing a padded or short group`(input: String) {
            let decoded = [Byte](base64Encoded: input)
            #expect(decoded == nil, "'\(input)' should be rejected, not silently truncated")
        }

        // Regression guard for F-001: earlier whitespace coverage only asserted
        // `decoded != nil`, which the pre-fix silent-truncation bug could
        // satisfy with a wrong (truncated) value just as easily as a correct one.
        @Test
        func `whitespace decoding produces the exact expected bytes`() {
            #expect([Byte](base64Encoded: "Zm9v\nYmFy") == [Byte]("foobar".utf8))
            #expect([Byte](base64Encoded: "Zm9v YmFy") == [Byte]("foobar".utf8))
        }
    }
}

// MARK: - F-004 Regression Tests (opt-in strictness)

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
        // "AB==": sextets A(0), B(1) — the low 4 bits of B's sextet don't map
        // onto the single decoded byte and are nonzero (canonical encoders
        // always emit 0 there), so this is a non-canonical encoding of 0x00.
        #expect(RFC_4648.Base64.decode("AB==", strictness: .lenient) == [0x00])
        #expect(RFC_4648.Base64.decode("AB==", strictness: .strict) == nil)

        // "AA==" is the canonical encoding of the same byte and must still
        // succeed under strict.
        #expect(RFC_4648.Base64.decode("AA==", strictness: .strict) == [0x00])
    }
}

// MARK: - F-003 Regression Tests (decode(as:) octet semantics)

extension RFC_4648.Base64.Test.`Edge Case` {
    @Test
    func `decode(as:) matches the documented doc-example value`() throws {
        // The doc comment on decode(as:) claims "AQIDBA==" decodes to
        // 0x01020304 — pre-fix, the positional-sextet accumulator returned
        // nil for this input (6 sextets * 6 bits = 36 bits > UInt32's 32).
        let value: UInt32? = RFC_4648.Base64.decode(try [ASCII.Code]("AQIDBA==".utf8))
        #expect(value == 0x0102_0304)
    }

    @Test
    func `decode(as:) matches octet semantics of the FixedWidthInteger init family`() throws {
        let value = UInt32(123_456)
        let encoded = String.base64(value)
        let codes = try [ASCII.Code](encoded.utf8)

        #expect(RFC_4648.Base64.decode(codes, as: UInt32.self) == value)
        #expect(RFC_4648.Base64.decode(codes, as: UInt32.self) == UInt32(base64Encoded: encoded))
    }

    @Test
    func `decode(as:) rejects a byte count that does not match the target width`() throws {
        let encoded = String.base64(UInt32(123_456))  // 4 bytes
        let codes = try [ASCII.Code](encoded.utf8)
        #expect(RFC_4648.Base64.decode(codes, as: UInt8.self) == nil)
        #expect(RFC_4648.Base64.decode(codes, as: UInt64.self) == nil)
    }

    @Test
    func `decode(as:) on empty input returns nil like the FixedWidthInteger init family`() {
        // Pre-fix, decode(as:) returned 0 for empty input regardless of T,
        // while `UInt32(base64Encoded: "")` already returned nil (0 decoded
        // bytes never matches T's width) — an unqualified inconsistency.
        let value: UInt32? = RFC_4648.Base64.decode([ASCII.Code]())
        #expect(value == nil)
        #expect(value == UInt32(base64Encoded: ""))
    }
}
