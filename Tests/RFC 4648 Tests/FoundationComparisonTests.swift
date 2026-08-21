import RFC_4648
import Testing

#if canImport(Foundation)
    import Foundation

    @Suite("Foundation Comparison Tests")
    struct FoundationComparisonTests {

        @Test
        func `Base64 encoding matches Foundation`() {
            let testCases: [[Byte]] = [
                [],
                [Byte]("f".utf8),
                [Byte]("fo".utf8),
                [Byte]("foo".utf8),
                [Byte]("foob".utf8),
                [Byte]("fooba".utf8),
                [Byte]("foobar".utf8),
                [0x00, 0xFF, 0x80, 0x7F],
                [Byte]("The quick brown fox jumps over the lazy dog".utf8),
                (0..<100).map { Byte(UInt8($0 % 256)) },
            ]

            for bytes in testCases {
                let ourEncoding = String.base64(bytes, padding: true)
                let foundationEncoding = Data(bytes.underlying).base64EncodedString()

                #expect(
                    ourEncoding == foundationEncoding,
                    "Our encoding: \(ourEncoding), Foundation: \(foundationEncoding)"
                )
            }
        }

        @Test
        func `Base64 decoding matches Foundation`() {
            let testCases = [
                "",
                "Zg==",
                "Zm8=",
                "Zm9v",
                "Zm9vYg==",
                "Zm9vYmE=",
                "Zm9vYmFy",
                "VGhlIHF1aWNrIGJyb3duIGZveCBqdW1wcyBvdmVyIHRoZSBsYXp5IGRvZw==",
            ]

            for encoded in testCases {
                let ourDecoding = [Byte](base64Encoded: encoded)
                let foundationDecoding = Data(base64Encoded: encoded).map { [Byte]($0) }

                #expect(
                    ourDecoding == foundationDecoding,
                    "Our decoding: \(String(describing: ourDecoding)), Foundation: \(String(describing: foundationDecoding))"
                )
            }
        }

        @Test
        func `Base64 round-trip matches Foundation`() {
            let testBytes: [[Byte]] = [
                [Byte]("Hello, World!".utf8),
                (0..<255).map { Byte(UInt8($0)) },
                Array(repeating: 0xFF, count: 100),
                Array(repeating: 0x00, count: 100),
            ]

            for bytes in testBytes {

                let ourEncoded = String.base64(bytes)
                let ourDecoded = [Byte](base64Encoded: ourEncoded)

                let foundationEncoded = Data(bytes.underlying).base64EncodedString()
                let foundationDecoded = Data(base64Encoded: foundationEncoded).map { [Byte]($0) }

                #expect(ourEncoded == foundationEncoded)
                #expect(ourDecoded == foundationDecoded)
                #expect(ourDecoded == bytes)
            }
        }

        @Test
        func `Base64 encoding with line length matches Foundation`() {
            let longBytes = (0..<200).map { Byte(UInt8($0 % 256)) }

            let ourEncoded = String.base64(longBytes)

            let foundationEncoded = Data(longBytes.underlying).base64EncodedString()

            #expect(ourEncoded == foundationEncoded)
            #expect(!ourEncoded.contains("\n"))
            #expect(!ourEncoded.contains("\r"))
        }

        @Test
        func `Base64 invalid characters rejected by both`() {
            let invalidChars = "!!!!"

            let ourResult = [Byte](base64Encoded: invalidChars)
            let foundationResult = Data(base64Encoded: invalidChars)

            #expect(ourResult == nil)
            #expect(foundationResult == nil)
        }

        @Test
        func `Base64 invalid length rejected by both`() {
            let invalidLength = "Zm9"

            let ourResult = [Byte](base64Encoded: invalidLength)
            let foundationResult = Data(base64Encoded: invalidLength)

            #expect(ourResult == nil)
            #expect(foundationResult == nil)
        }

        @Test
        func `Base64 edge case padding differences`() {

            let onlyPadding = "===="
            let ourResult1 = [Byte](base64Encoded: onlyPadding)
            #expect(ourResult1 == nil, "RFC 4648: Only padding is invalid")

            let tooMuchPadding = "Zm9v==="
            let ourResult2 = [Byte](base64Encoded: tooMuchPadding)
            #expect(ourResult2 == nil, "RFC 4648: Too much padding is invalid")
        }

        @Test
        func `Base64 whitespace handling - RFC 4648 compliance`() {

            let withWhitespace = "Zm9v\nYmFy"
            let withoutWhitespace = "Zm9vYmFy"

            let ourDecoded = [Byte](base64Encoded: withWhitespace)
            #expect(ourDecoded == [Byte](base64Encoded: withoutWhitespace))
            #expect(ourDecoded == [Byte]("foobar".utf8))

            let foundationDecoded = Data(base64Encoded: withWhitespace)
            #expect(foundationDecoded == nil, "Foundation rejects whitespace in base64")

            let ourClean = [Byte](base64Encoded: withoutWhitespace)
            let foundationClean = Data(base64Encoded: withoutWhitespace).map { [Byte]($0) }
            #expect(ourClean == foundationClean)
        }

        @Test
        func `Base64 empty string handling`() {
            let emptyBytes: [Byte] = []

            let ourEncoded = String.base64(emptyBytes)
            let foundationEncoded = Data(emptyBytes).base64EncodedString()

            #expect(ourEncoded == foundationEncoded)
            #expect(ourEncoded.isEmpty)

            let ourDecoded = [Byte](base64Encoded: "")
            let foundationDecoded = Data(base64Encoded: "").map { [Byte]($0) }

            #expect(ourDecoded == foundationDecoded)
            #expect(ourDecoded == [])
        }

        @Test
        func `Base64 large data matches Foundation`() {

            let largeBytes = (0..<(1024 * 1024)).map { Byte(UInt8($0 % 256)) }

            let ourEncoded = String.base64(largeBytes)
            let foundationEncoded = Data(largeBytes.underlying).base64EncodedString()

            #expect(ourEncoded == foundationEncoded)

            let ourDecoded = [Byte](base64Encoded: ourEncoded)
            let foundationDecoded = Data(base64Encoded: foundationEncoded).map { [Byte]($0) }

            #expect(ourDecoded == foundationDecoded)
            #expect(ourDecoded == largeBytes)
        }

        @Test
        func `Base64 all byte values match Foundation`() {
            let allBytes = (0...255).map { Byte(UInt8($0)) }

            let ourEncoded = String.base64(allBytes)
            let foundationEncoded = Data(allBytes.underlying).base64EncodedString()

            #expect(ourEncoded == foundationEncoded)

            let ourDecoded = [Byte](base64Encoded: ourEncoded)
            let foundationDecoded = Data(base64Encoded: foundationEncoded).map { [Byte]($0) }

            #expect(ourDecoded == foundationDecoded)
            #expect(ourDecoded == allBytes)
        }

        @Test
        func `Hex encoding produces valid output`() {
            let testBytes: [Byte] = [0x00, 0x0F, 0xFF, 0xAB, 0xCD, 0xEF]

            let ourHex = String.hex(testBytes)

            #expect(ourHex == "000fffabcdef")

            let decoded = [Byte](hexEncoded: ourHex)
            #expect(decoded == testBytes)
        }

        @Test
        func `Hex uppercase encoding produces valid output`() {
            let testBytes: [Byte] = [0x00, 0x0F, 0xFF, 0xAB, 0xCD, 0xEF]

            let ourHexUpper = String.hex(testBytes, uppercase: true)

            #expect(ourHexUpper == "000FFFABCDEF")

            let decoded = [Byte](hexEncoded: ourHexUpper)
            #expect(decoded == testBytes)
        }

        @Test
        func `Base64 all single-byte values match Foundation`() {
            for byte in 0...255 {
                let bytes: [Byte] = [Byte(UInt8(byte))]

                let ourEncoded = String.base64(bytes)
                let foundationEncoded = Data(bytes.underlying).base64EncodedString()

                #expect(
                    ourEncoded == foundationEncoded,
                    "Mismatch for byte \(byte): our=\(ourEncoded), foundation=\(foundationEncoded)"
                )

                let ourDecoded = [Byte](base64Encoded: ourEncoded)
                #expect(ourDecoded == bytes)
            }
        }

        @Test
        func `Base64 all two-byte combinations (sampled)`() {

            for i in stride(from: 0, through: 255, by: 17) {
                for j in stride(from: 0, through: 255, by: 17) {
                    let bytes: [Byte] = [Byte(UInt8(i)), Byte(UInt8(j))]

                    let ourEncoded = String.base64(bytes)
                    let foundationEncoded = Data(bytes.underlying).base64EncodedString()

                    #expect(
                        ourEncoded == foundationEncoded,
                        "Mismatch for [\(i), \(j)]"
                    )
                }
            }
        }

        @Test
        func `Base64 all three-byte combinations (sampled)`() {

            for i in stride(from: 0, through: 255, by: 51) {
                for j in stride(from: 0, through: 255, by: 51) {
                    for k in stride(from: 0, through: 255, by: 51) {
                        let bytes: [Byte] = [Byte(UInt8(i)), Byte(UInt8(j)), Byte(UInt8(k))]

                        let ourEncoded = String.base64(bytes)
                        let foundationEncoded = Data(bytes.underlying).base64EncodedString()

                        #expect(ourEncoded == foundationEncoded)
                    }
                }
            }
        }

        @Test(
            arguments: [
                1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
                15, 16, 17, 31, 32, 33, 63, 64, 65,
                100, 127, 128, 129, 255, 256, 257,
                511, 512, 513, 1000, 1023, 1024, 1025,
            ]
        )
        func `Base64 specific lengths match Foundation`(length: Int) {
            let bytes = (0..<length).map { Byte(UInt8($0 % 256)) }

            let ourEncoded = String.base64(bytes)
            let foundationEncoded = Data(bytes.underlying).base64EncodedString()

            #expect(
                ourEncoded == foundationEncoded,
                "Length \(length): our=\(ourEncoded.prefix(50))..., foundation=\(foundationEncoded.prefix(50))..."
            )

            let ourDecoded = [Byte](base64Encoded: ourEncoded)
            let foundationDecoded = Data(base64Encoded: foundationEncoded).map { [Byte]($0) }

            #expect(ourDecoded == foundationDecoded)
            #expect(ourDecoded == bytes)
        }

        @Test
        func `Base64 random data patterns match Foundation`() {

            var generator = SeededRandomNumberGenerator(seed: 42)

            for _ in 0..<100 {
                let length = Int.random(in: 1...500, using: &generator)
                let bytes: [Byte] = (0..<length).map { _ in
                    Byte(UInt8.random(in: 0...255, using: &generator))
                }

                let ourEncoded = String.base64(bytes)
                let foundationEncoded = Data(bytes.underlying).base64EncodedString()

                #expect(ourEncoded == foundationEncoded)

                let ourDecoded = [Byte](base64Encoded: ourEncoded)
                #expect(ourDecoded == bytes)
            }
        }

        @Test(
            arguments: [
                "Hello, World!",
                "The quick brown fox jumps over the lazy dog",
                "1234567890",
                "!@#$%^&*()_+-=[]{}|;':\",./<>?",
                "αβγδεζηθικλμνξοπρστυφχψω",
                "你好世界",
                "こんにちは世界",
                "🚀🌟💻🎉🔥",
                "Iñtërnâtiônàlizætiøn",
                "",
                " ",
                "\n\r\t",
                String(repeating: "A", count: 1000),
                String(repeating: "😀", count: 100),
            ]
        )
        func `Base64 UTF-8 strings match Foundation`(input: String) {
            let bytes = [Byte](input.utf8)

            let ourEncoded = String.base64(bytes)
            let foundationEncoded = Data(bytes.underlying).base64EncodedString()

            #expect(
                ourEncoded == foundationEncoded,
                "Input: \(input.prefix(50))"
            )

            let ourDecoded = [Byte](base64Encoded: ourEncoded)
            let foundationDecoded = Data(base64Encoded: foundationEncoded).map { [Byte]($0) }

            #expect(ourDecoded == foundationDecoded)
            #expect(ourDecoded == bytes)
        }

        @Test(
            arguments: [
                (1, "AA=="),
                (2, "AAA="),
                (3, "AAAA"),
                (4, "AAAAAA=="),
                (5, "AAAAAAA="),
                (6, "AAAAAAAA"),
            ]
        )
        func `Base64 padding scenarios match Foundation`(length: Int, expectedPattern: String) {
            let bytes: [Byte] = Array(repeating: 0, count: length)

            let ourEncoded = String.base64(bytes)
            let foundationEncoded = Data(bytes.underlying).base64EncodedString()

            #expect(ourEncoded == foundationEncoded)
            #expect(ourEncoded == expectedPattern)
        }

        @Test
        func `Base64 BinaryInteger UInt8 values match Foundation`() {
            for value in [UInt8.min, 1, 127, 128, 255, UInt8.max] {
                let bytes = withUnsafeBytes(of: value.bigEndian) { [Byte]($0) }

                let ourEncoded = String.base64(value)
                let foundationEncoded = Data(bytes.underlying).base64EncodedString()

                #expect(
                    ourEncoded == foundationEncoded,
                    "UInt8(\(value)): our=\(ourEncoded), foundation=\(foundationEncoded)"
                )
            }
        }

        @Test
        func `Base64 BinaryInteger UInt16 values match Foundation`() {
            let values: [UInt16] = [0, 1, 255, 256, 32767, 32768, 65535, UInt16.max]

            for value in values {
                let bytes = withUnsafeBytes(of: value.bigEndian) { [Byte]($0) }

                let ourEncoded = String.base64(value)
                let foundationEncoded = Data(bytes.underlying).base64EncodedString()

                #expect(
                    ourEncoded == foundationEncoded,
                    "UInt16(\(value)): our=\(ourEncoded), foundation=\(foundationEncoded)"
                )
            }
        }

        @Test
        func `Base64 BinaryInteger UInt32 values match Foundation`() {
            let values: [UInt32] = [
                0, 1, 255, 256, 65535, 65536,
                123_456, 0xDEAD_BEEF, 0x1234_5678,
                UInt32.max,
            ]

            for value in values {
                let bytes = withUnsafeBytes(of: value.bigEndian) { [Byte]($0) }

                let ourEncoded = String.base64(value)
                let foundationEncoded = Data(bytes.underlying).base64EncodedString()

                #expect(
                    ourEncoded == foundationEncoded,
                    "UInt32(\(value)): our=\(ourEncoded), foundation=\(foundationEncoded)"
                )
            }
        }

        @Test
        func `Base64 BinaryInteger UInt64 values match Foundation`() {
            let values: [UInt64] = [
                0, 1, 255, 256, 65535, 65536,
                UInt64(UInt32.max),
                0x1234_5678_9ABC_DEF0,
                UInt64.max,
            ]

            for value in values {
                let bytes = withUnsafeBytes(of: value.bigEndian) { [Byte]($0) }

                let ourEncoded = String.base64(value)
                let foundationEncoded = Data(bytes.underlying).base64EncodedString()

                #expect(
                    ourEncoded == foundationEncoded,
                    "UInt64(\(value)): our=\(ourEncoded), foundation=\(foundationEncoded)"
                )
            }
        }

        @Test
        func `Base64 consecutive byte values match Foundation`() {
            for start in stride(from: 0, through: 200, by: 50) {
                let length = 55
                let bytes = (start..<min(start + length, 256)).map { Byte(UInt8($0)) }

                let ourEncoded = String.base64(bytes)
                let foundationEncoded = Data(bytes.underlying).base64EncodedString()

                #expect(ourEncoded == foundationEncoded)
            }
        }

        @Test
        func `Base64 alternating patterns match Foundation`() {
            let patterns: [[Byte]] = [
                Array(repeating: [0x00, 0xFF], count: 50).flatMap { $0 },
                Array(repeating: [0xAA, 0x55], count: 50).flatMap { $0 },
                Array(repeating: [0x00, 0x80, 0xFF], count: 50).flatMap { $0 },
                (0..<100).map { Byte(UInt8($0 % 2 == 0 ? 0xFF : 0x00)) },
            ]

            for pattern in patterns {
                let ourEncoded = String.base64(pattern)
                let foundationEncoded = Data(pattern).base64EncodedString()

                #expect(ourEncoded == foundationEncoded)
            }
        }

        @Test
        func `Base64 powers of two lengths match Foundation`() {
            for power in 0...10 {
                let length = 1 << power
                let bytes = (0..<length).map { Byte(UInt8($0 % 256)) }

                let ourEncoded = String.base64(bytes)
                let foundationEncoded = Data(bytes.underlying).base64EncodedString()

                #expect(
                    ourEncoded == foundationEncoded,
                    "Length 2^\(power) = \(length)"
                )
            }
        }

        @Test
        func `Base64 decode various valid inputs match Foundation`() {
            let validInputs = [
                "YQ==",
                "YWI=",
                "YWJj",
                "YWJjZA==",
                "dGVzdA==",
                "SGVsbG8gV29ybGQh",
                "AAAA",
                "////",
                "++++",
                "MDEyMzQ1Njc4OQ==",
            ]

            for encoded in validInputs {
                let ourDecoded = [Byte](base64Encoded: encoded)
                let foundationDecoded = Data(base64Encoded: encoded).map { [Byte]($0) }

                #expect(
                    ourDecoded == foundationDecoded,
                    "Decoding '\(encoded)'"
                )
            }
        }

        @Test
        func `Base64 decode with padding matches Foundation`() {

            let testCases: [(padded: String, expected: [Byte])] = [
                ("YQ==", [Byte]("a".utf8)),
                ("YWI=", [Byte]("ab".utf8)),
                ("YWJj", [Byte]("abc".utf8)),
                ("YWJjZA==", [Byte]("abcd".utf8)),
            ]

            for (padded, expectedBytes) in testCases {

                let ourDecoded = [Byte](base64Encoded: padded)

                let foundationDecoded = Data(base64Encoded: padded).map { [Byte]($0) }

                #expect(ourDecoded != nil, "Our implementation should decode '\(padded)'")
                #expect(foundationDecoded != nil, "Foundation should decode '\(padded)'")

                #expect(
                    ourDecoded == foundationDecoded,
                    "Results should match for '\(padded)'"
                )

                #expect(
                    ourDecoded == expectedBytes,
                    "Should decode to expected bytes"
                )
            }
        }

        @Test
        func `Base64 very large data matches Foundation`() {

            let largeSize = 10 * 1024 * 1024
            let largeBytes = (0..<largeSize).map { Byte(UInt8($0 % 256)) }

            let ourEncoded = String.base64(largeBytes)
            let foundationEncoded = Data(largeBytes.underlying).base64EncodedString()

            #expect(
                ourEncoded == foundationEncoded,
                "10MB encoding should match"
            )

            let expectedLength = ((largeSize + 2) / 3) * 4
            #expect(ourEncoded.count == expectedLength)
            #expect(foundationEncoded.count == expectedLength)
        }

        @Test
        func `Base64 repetitive patterns at scale match Foundation`() {
            let patterns: [[Byte]] = [
                Array(repeating: 0x00, count: 10000),
                Array(repeating: 0xFF, count: 10000),
                Array(repeating: 0xAA, count: 10000),
                Array(repeating: 0x55, count: 10000),
            ]

            for pattern in patterns {
                let ourEncoded = String.base64(pattern)
                let foundationEncoded = Data(pattern).base64EncodedString()

                #expect(ourEncoded == foundationEncoded)
            }
        }
    }

    struct SeededRandomNumberGenerator: RandomNumberGenerator {
        private var state: UInt64

        init(seed: UInt64) {
            state = seed
        }
    }

    extension SeededRandomNumberGenerator {
        mutating func next() -> UInt64 {

            state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
            return state
        }
    }

#endif
