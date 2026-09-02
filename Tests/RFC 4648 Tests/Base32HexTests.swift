import RFC_4648
import Testing

extension RFC_4648.Base32.Hex {
    @Suite("Base32-HEX Encoding Tests")
    struct Test {

        @Test(
            arguments: [
                ("", ""),
                ("f", "CO======"),
                ("fo", "CPNG===="),
                ("foo", "CPNMU==="),
                ("foob", "CPNMUOG="),
                ("fooba", "CPNMUOJ1"),
                ("foobar", "CPNMUOJ1E8======"),
            ]
        )
        func `RFC 4648 test vectors`(input: String, expected: String) {
            let bytes = input.utf8.map(Byte.init(bitPattern:))
            let encoded = String.base32.hex(bytes)
            #expect(encoded == expected, "Encoding '\(input)' should produce '\(expected)'")

            let decoded = [Byte](base32HexEncoded: encoded)
            #expect(decoded == bytes, "Round-trip failed for '\(input)'")
        }

        @Test
        func `Base32-HEX uses correct alphabet (0-9, A-V)`() {
            let input: [Byte] = "The quick brown fox jumps over the lazy dog".utf8.map(Byte.init(bitPattern:))
            let encoded = String.base32.hex(input, padding: false)

            for char in encoded {
                let isValid = (char >= "0" && char <= "9") || (char >= "A" && char <= "V")
                #expect(isValid)
            }
        }

        @Test
        func `Base32-HEX differs from Base32`() {
            let input: [Byte] = "foo".utf8.map(Byte.init(bitPattern:))

            let base32 = String.base32(input, padding: false)
            let base32hex = String.base32.hex(input, padding: false)

            #expect(base32 != base32hex)

            #expect([Byte](base32Encoded: base32) == input)
            #expect([Byte](base32HexEncoded: base32hex) == input)
        }

        @Test(
            arguments: [
                "CPNMU===",
                "cpnmu===",
                "CpNmU===",
                "cPnMu===",
            ]
        )
        func `Base32-HEX decoding is case-insensitive`(encoded: String) {
            let expected: [Byte] = "foo".utf8.map(Byte.init(bitPattern:))
            let decoded = [Byte](base32HexEncoded: encoded)
            #expect(decoded == expected, "Case-insensitive decoding should work for '\(encoded)'")
        }

        @Test
        func `Base32-HEX encoding produces uppercase`() {
            let input: [Byte] = "hello".utf8.map(Byte.init(bitPattern:))
            let encoded = String.base32.hex(input)

            for char in encoded {
                if char.isLetter {
                    #expect(char.isUppercase)
                }
            }
        }

        @Test(
            arguments: [
                ("f".utf8.map(Byte.init(bitPattern:)), false, "CO", false),
                ("f".utf8.map(Byte.init(bitPattern:)), true, "CO======", true),
                ("foo".utf8.map(Byte.init(bitPattern:)), false, "CPNMU", false),
                ("foo".utf8.map(Byte.init(bitPattern:)), true, "CPNMU===", true),
            ]
        )
        func `Base32-HEX padding variations`(
            input: [Byte],
            padding: Bool,
            expectedEncoded: String,
            shouldHavePadding: Bool
        ) {
            let encoded = String.base32.hex(input, padding: padding)
            #expect(encoded == expectedEncoded)
            #expect(encoded.contains("=") == shouldHavePadding)

            let decoded = [Byte](base32HexEncoded: encoded)
            #expect(decoded == input)
        }

        @Test(
            arguments: [
                "CPNMUOJ1\nE8======",
                "CPNMUOJ1\t\tE8======",
                "CPNMUOJ1 E8======",
                "CPNMUOJ1 \t E8======",
            ]
        )
        func `Base32-HEX whitespace handling`(input: String) {
            let decoded = [Byte](base32HexEncoded: input)
            #expect(decoded == "foobar".utf8.map(Byte.init(bitPattern:)), "Whitespace should be ignored in '\(input)'")
        }

        @Test(
            arguments: [
                "CPNMW===",
                "CPNMZ===",
                "C",
                "CPNM!@#$",
                "========",
            ]
        )
        func `Base32-HEX decoding rejects invalid input`(input: String) {
            let decoded = [Byte](base32HexEncoded: input)
            #expect(decoded == nil, "\(input) should be rejected")
        }

        @Test(
            arguments: [
                (([0x00, 0xFF, 0x80, 0x7F] as [UInt8]).map(Byte.init(bitPattern:)), nil),
                (([0x00, 0x00, 0x00, 0x00, 0x00] as [UInt8]).map(Byte.init(bitPattern:)), "00000000"),
                (([0x00, 0x01, 0x02, 0x03, 0x04] as [UInt8]).map(Byte.init(bitPattern:)), nil),
                (([0xFF, 0xFF, 0xFF, 0xFF, 0xFF] as [UInt8]).map(Byte.init(bitPattern:)), nil),
            ]
        )
        func `Base32-HEX binary data patterns`(input: [Byte], expectedEncoded: String?) {
            let encoded = String.base32.hex(input)

            if let expected = expectedEncoded {
                #expect(encoded == expected)
            }

            let decoded = [Byte](base32HexEncoded: encoded)
            #expect(decoded == input)
        }

        @Test
        func `Base32-HEX round-trip various sizes`() {
            for size in [1, 2, 3, 4, 5, 10, 20, 50, 100] {
                let input: [Byte] = (0..<size).map { Byte(bitPattern: UInt8($0 % 256)) }
                let encoded = String.base32.hex(input)
                let decoded = [Byte](base32HexEncoded: encoded)
                #expect(decoded == input)
            }
        }

        @Test
        func `Base32-HEX round-trip long string`() {
            let longString = String(repeating: "Hello, World! ", count: 100)
            let input = longString.utf8.map(Byte.init(bitPattern:))
            let encoded = String.base32.hex(input)
            let decoded = [Byte](base32HexEncoded: encoded)
            #expect(decoded == input)
        }

        @Test
        func `Base32-HEX maintains lexicographic order`() {

            let input1: [Byte] = ([0x00] as [UInt8]).map(Byte.init(bitPattern:))
            let input2: [Byte] = ([0x01] as [UInt8]).map(Byte.init(bitPattern:))
            let input3: [Byte] = ([0xFF] as [UInt8]).map(Byte.init(bitPattern:))

            let encoded1 = String.base32.hex(input1, padding: false)
            let encoded2 = String.base32.hex(input2, padding: false)
            let encoded3 = String.base32.hex(input3, padding: false)

            #expect(encoded1 < encoded2)
            #expect(encoded2 < encoded3)
        }
    }
}

extension RFC_4648.Base32.Hex.Test {
    @Suite
    struct `Edge Case` {
        @Test
        func `decode(as:) matches octet semantics of the FixedWidthInteger init family`() throws {
            let value = UInt32(123_456)
            let encoded = String.base32.hex(value)
            let codes = try encoded.utf8.map { try ASCII.Code(Byte(bitPattern: $0)) }

            #expect(RFC_4648.Base32.Hex.decode(codes, as: UInt32.self) == value)
            #expect(
                RFC_4648.Base32.Hex.decode(codes, as: UInt32.self)
                    == UInt32(base32HexEncoded: encoded)
            )
        }

        @Test
        func `decode(as:) rejects a byte count that does not match the target width`() throws {
            let encoded = String.base32.hex(UInt32(123_456))
            let codes = try encoded.utf8.map { try ASCII.Code(Byte(bitPattern: $0)) }
            #expect(RFC_4648.Base32.Hex.decode(codes, as: UInt8.self) == nil)
            #expect(RFC_4648.Base32.Hex.decode(codes, as: UInt64.self) == nil)
        }

        @Test
        func `decode(as:) on empty input returns nil like the FixedWidthInteger init family`() {
            let value: UInt32? = RFC_4648.Base32.Hex.decode([ASCII.Code]())
            #expect(value == nil)
            #expect(value == UInt32(base32HexEncoded: ""))
        }
    }
}
