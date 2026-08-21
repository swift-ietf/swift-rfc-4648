import RFC_4648
import Testing

extension RFC_4648.Base16 {
    @Suite("Hex Encoding Tests")
    struct Test {

        @Test(
            arguments: [
                ("", ""),
                ("f", "66"),
                ("fo", "666f"),
                ("foo", "666f6f"),
                ("foob", "666f6f62"),
                ("fooba", "666f6f6261"),
                ("foobar", "666f6f626172"),
            ]
        )
        func `RFC 4648 test vectors`(input: String, expected: String) {
            let bytes = [Byte](input.utf8)
            let encoded = String.hex(bytes)
            #expect(encoded == expected, "Encoding '\(input)' should produce '\(expected)'")

            let decoded = [Byte](hexEncoded: encoded)
            #expect(decoded == bytes, "Round-trip failed for '\(input)'")
        }

        @Test
        func `Hex encoding lowercase by default`() {
            let input: [Byte] = [0xFF, 0xAB, 0xCD]
            let encoded = String.hex(input)
            #expect(encoded == "ffabcd")
        }

        @Test
        func `Hex encoding uppercase when requested`() {
            let input: [Byte] = [0xFF, 0xAB, 0xCD]
            let encoded = String.hex(input, uppercase: true)
            #expect(encoded == "FFABCD")
        }

        @Test(
            arguments: [
                "ffab",
                "FFAB",
                "FfAb",
                "fFaB",
            ]
        )
        func `Hex decoding is case-insensitive`(encoded: String) {
            let expected: [Byte] = [0xFF, 0xAB]
            let decoded = [Byte](hexEncoded: encoded)
            #expect(decoded == expected, "Case-insensitive decoding should work for '\(encoded)'")
        }

        @Test(
            arguments: [
                ("0xFF", [0xFF]),
                ("0XFF", [0xFF]),
                ("FF", [0xFF]),
                ("0xDEADBEEF", [0xDE, 0xAD, 0xBE, 0xEF]),
                ("0Xdeadbeef", [0xDE, 0xAD, 0xBE, 0xEF]),
            ]
        )
        func `Hex decoding with various prefix formats`(input: String, expected: [Byte]) {
            let decoded = [Byte](hexEncoded: input)
            #expect(decoded == expected, "'\(input)' should decode to \(expected)")
        }

        @Test(
            arguments: [
                "DE AD BE EF",
                "DE\nAD\nBE\nEF",
                "DE\tAD\tBE\tEF",
                "DE AD\nBE\tEF",
                "DEADBEEF",
            ]
        )
        func `Hex decoding with whitespace`(input: String) {
            let expected: [Byte] = [0xDE, 0xAD, 0xBE, 0xEF]
            let decoded = [Byte](hexEncoded: input)
            #expect(decoded == expected, "Whitespace should be ignored in '\(input)'")
        }

        @Test(
            arguments: [
                "GGGG",
                "FFF",
                "FF!!",
                "#FF5733",
            ]
        )
        func `Hex decoding rejects invalid input`(input: String) {
            let decoded = [Byte](hexEncoded: input)
            #expect(decoded == nil, "\(input) should be rejected")
        }

        @Test
        func `Hex encoding all byte values`() {
            for byte in 0...255 {
                let input: [Byte] = [Byte(UInt8(byte))]
                let encoded = String.hex(input)
                let decoded = [Byte](hexEncoded: encoded)
                #expect(decoded == input)
            }
        }

        @Test
        func `Hex encoding all zeros`() {
            let input: [Byte] = [0x00, 0x00, 0x00]
            let encoded = String.hex(input)
            #expect(encoded == "000000")

            let decoded = [Byte](hexEncoded: encoded)
            #expect(decoded == input)
        }

        @Test
        func `Hex encoding all ones`() {
            let input: [Byte] = [0xFF, 0xFF, 0xFF]
            let encoded = String.hex(input)
            #expect(encoded == "ffffff")

            let decoded = [Byte](hexEncoded: encoded)
            #expect(decoded == input)
        }

        @Test
        func `Hex encoding sequential bytes`() {
            let input: [Byte] = [0x00, 0x01, 0x02, 0x03, 0x04, 0x05]
            let encoded = String.hex(input)
            #expect(encoded == "000102030405")

            let decoded = [Byte](hexEncoded: encoded)
            #expect(decoded == input)
        }

        @Test
        func `Hex encoding SHA-256 hash`() {

            let hash: [Byte] = [
                0xE3, 0xB0, 0xC4, 0x42, 0x98, 0xFC, 0x1C, 0x14,
                0x9A, 0xFB, 0xF4, 0xC8, 0x99, 0x6F, 0xB9, 0x24,
                0x27, 0xAE, 0x41, 0xE4, 0x64, 0x9B, 0x93, 0x4C,
                0xA4, 0x95, 0x99, 0x1B, 0x78, 0x52, 0xB8, 0x55,
            ]

            let encoded = String.hex(hash)
            #expect(encoded.count == 64)

            let decoded = [Byte](hexEncoded: encoded)
            #expect(decoded == hash)
        }

        @Test
        func `Hex encoding UUID bytes`() {

            let uuid: [Byte] = [
                0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC, 0xDE, 0xF0,
                0x12, 0x34, 0x56, 0x78, 0x9A, 0xBC, 0xDE, 0xF0,
            ]

            let encoded = String.hex(uuid)
            let decoded = [Byte](hexEncoded: encoded)
            #expect(decoded == uuid)
        }

        @Test
        func `Hex encoding color values`() {

            let color: [Byte] = [0xFF, 0x57, 0x33]
            let encoded = String.hex(color, uppercase: true)
            #expect(encoded == "FF5733")

            let decoded = [Byte](hexEncoded: "#FF5733")
            #expect(decoded == nil)

            let decoded2 = [Byte](hexEncoded: "FF5733")
            #expect(decoded2 == color)
        }

        @Test
        func `Hex round-trip various sizes`() {
            for size in [1, 2, 10, 100, 1000] {
                let input: [Byte] = (0..<size).map { Byte(UInt8($0 % 256)) }
                let encoded = String.hex(input)
                let decoded = [Byte](hexEncoded: encoded)
                #expect(decoded == input)
            }
        }

        @Test
        func `Hex round-trip long string`() {
            let longString = String(repeating: "Hello, World! ", count: 100)
            let input = [Byte](longString.utf8)
            let encoded = String.hex(input)
            let decoded = [Byte](hexEncoded: encoded)
            #expect(decoded == input)
        }

        @Test(
            arguments: [
                "DEAD",
                "0xDEAD",
                "DE AD",
                "dead",
                "DeAd",
                "0xde ad",
            ]
        )
        func `Hex decoding common format variations`(input: String) {
            let expected: [Byte] = [0xDE, 0xAD]
            let decoded = [Byte](hexEncoded: input)
            #expect(decoded == expected, "'\(input)' should decode to \(expected)")
        }

        @Test
        func `Hex encoding produces consistent output`() {
            let input: [Byte] = [0xAB, 0xCD, 0xEF]

            let encoded1 = String.hex(input)
            let encoded2 = String.hex(input)

            #expect(encoded1 == encoded2)
        }
    }
}

extension RFC_4648.Base16.Test {
    @Suite
    struct `Edge Case` {
        @Test
        func `leading whitespace before a pair does not swap its nibbles`() {

            #expect([Byte](hexEncoded: " DEAD") == [0xDE, 0xAD])
        }

        @Test
        func
            `whitespace between prefix-shaped digits and following digits leaves an odd count invalid`()
        {

            #expect([Byte](hexEncoded: "0 12") == nil)
        }

        @Test
        func `whitespace adjacent to the 0x prefix is skipped like any other whitespace`() {
            #expect([Byte](hexEncoded: "0x DEAD") == [0xDE, 0xAD])
            #expect([Byte](hexEncoded: "0 xDEAD") == [0xDE, 0xAD])
        }

        @Test
        func `0-prefixed and non-0-prefixed input behave identically around whitespace`() {
            #expect([Byte](hexEncoded: " 0123") == [Byte](hexEncoded: "0123"))
            #expect([Byte](hexEncoded: " 1234") == [Byte](hexEncoded: "1234"))
        }
    }
}
