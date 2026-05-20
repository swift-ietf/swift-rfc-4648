// Base64Tests.swift
// swift-rfc-4648
//
// Tests for RFC 4648 Section 4: Base64 Encoding

import RFC_4648
import Testing

@Suite("Base64 Encoding Tests")
struct Base64Tests {
    // MARK: - RFC 4648 Section 10 Test Vectors

    @Test(
        "RFC 4648 test vectors",
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
    func rFCVectors(input: String, expected: String) {
        let bytes = Array<Byte>(input.utf8)
        let encoded = String.base64(bytes)
        #expect(encoded == expected, "Encoding '\(input)' should produce '\(expected)'")

        let decoded = [Byte](base64Encoded: encoded)
        #expect(decoded == bytes, "Round-trip failed for '\(input)'")
    }

    // MARK: - Padding Tests

    @Test(
        "Base64 padding variations",
        arguments: [
            (Array<Byte>("f".utf8), false, "Zg", [Byte]?.none),  // no padding - decoding fails
            (Array<Byte>("f".utf8), true, "Zg==", Array<Byte>("f".utf8)),  // with padding - succeeds
            (Array<Byte>("fo".utf8), false, "Zm8", [Byte]?.none),  // no padding - fails
            (Array<Byte>("fo".utf8), true, "Zm8=", Array<Byte>("fo".utf8)),  // with padding - succeeds
            (Array<Byte>("foo".utf8), false, "Zm9v", Array<Byte>("foo".utf8)),  // no padding needed
            //            (Array<Byte>("foo".utf8), true, "Zm9v", Array<Byte>("foo".utf8)),  // padding doesn't hurt
        ]
    )
    func paddingVariations(
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
        "Base64 decoding with whitespace",
        arguments: [
            "Zm9v\nYmFy",  // newline
            "Zm9v\tYmFy",  // tab
            "Zm9v YmFy",  // space
            "Zm9v\n\t YmFy",  // mixed whitespace
        ]
    )
    func whitespaceHandling(input: String) {
        let decoded = [Byte](base64Encoded: input)
        #expect(decoded == Array<Byte>("foobar".utf8), "Whitespace should be ignored")
    }

    // MARK: - Invalid Input Tests

    @Test(
        "Base64 decoding rejects invalid input",
        arguments: [
            "Zm9v!!!!",  // invalid characters
            "Zm9",  // invalid length (not multiple of 4)
            "====",  // only padding
            "Z",  // too short
        ]
    )
    func invalidInput(input: String) {
        let decoded = [Byte](base64Encoded: input)
        #expect(decoded == nil, "\(input) should be rejected")
    }

    // MARK: - Binary Data Tests

    @Test(
        "Base64 binary data patterns",
        arguments: [
            ([0x00, 0xFF, 0x80, 0x7F], nil),  // mixed binary data
            ([0x00, 0x00, 0x00], "AAAA"),  // all zeros
            ([0xFF, 0xFF, 0xFF], "////"),  // all ones
        ]
    )
    func binaryDataPatterns(input: [Byte], expectedEncoded: String?) {
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
        let input = Array<Byte>(longString.utf8)
        let encoded = String.base64(input)
        let decoded = [Byte](base64Encoded: encoded)
        #expect(decoded == input)
    }
}
