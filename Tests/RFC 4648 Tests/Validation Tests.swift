import Testing

@testable import RFC_4648

extension RFC_4648 {
    @Suite("RFC 4648 Validation Tests")
    struct Test {

        @Test(
            arguments: [
                "",
                "Zg==",
                "Zm8=",
                "Zm9v",
                "Zm9vYg==",
                "Zm9vYmE=",
                "Zm9vYmFy",
                "VGhlIHF1aWNrIGJyb3duIGZveCBqdW1wcyBvdmVyIHRoZSBsYXp5IGRvZw==",
            ]
        )
        func `Valid Base64 strings`(input: String) {
            #expect(RFC_4648.Base64.isValid(input), "\(input) should be valid Base64")
        }

        @Test(
            arguments: [
                "!@#$",
                "Zm9",
                "====",
                "Z!9v",
                "Zm9v===",
            ]
        )
        func `Invalid Base64 strings`(input: String) {
            #expect(!RFC_4648.Base64.isValid(input), "\(input) should be invalid Base64")
        }

        @Test
        func `Base64 validation with whitespace`() {

            #expect(RFC_4648.Base64.isValid("Zm9v\nYmFy"))
            #expect(RFC_4648.Base64.isValid("Zm9v YmFy"))
            #expect(RFC_4648.Base64.isValid("Zm9v\tYmFy"))
        }

        @Test(
            arguments: [
                "",
                "Zg",
                "Zm8",
                "Zm9v",
                "Zm9vYg",
                "Zm9vYmE",
                "Zm9vYmFy",
                "A-B_",
            ]
        )
        func `Valid Base64URL strings`(input: String) {
            #expect(RFC_4648.Base64.URL.isValid(input), "\(input) should be valid Base64URL")
        }

        @Test(
            arguments: [
                "!@#$",
                "A+B/C",
            ]
        )
        func `Invalid Base64URL strings`(input: String) {
            #expect(!RFC_4648.Base64.URL.isValid(input), "\(input) should be invalid Base64URL")
        }

        @Test(
            arguments: [
                "",
                "MZXW6===",
                "MZXW6YTBOI======",
                "JBSWY3DPEBLW64TMMQ======",
            ]
        )
        func `Valid Base32 strings`(input: String) {
            #expect(RFC_4648.Base32.isValid(input), "\(input) should be valid Base32")
        }

        @Test
        func `Base32 case insensitive validation`() {
            #expect(RFC_4648.Base32.isValid("MZXW6==="))
            #expect(RFC_4648.Base32.isValid("mzxw6==="))
            #expect(RFC_4648.Base32.isValid("MzXw6==="))
        }

        @Test(
            arguments: [
                "189",
                "ABC!@#",
                "====",
            ]
        )
        func `Invalid Base32 strings`(input: String) {
            #expect(!RFC_4648.Base32.isValid(input), "\(input) should be invalid Base32")
        }

        @Test(
            arguments: [
                "",
                "CPNMU===",
                "CPNMUOJ1",
                "91IMOR3F41BMUSJCCG======",
            ]
        )
        func `Valid Base32-HEX strings`(input: String) {
            #expect(RFC_4648.Base32.Hex.isValid(input), "\(input) should be valid Base32-HEX")
        }

        @Test
        func `Base32-HEX case insensitive validation`() {
            #expect(RFC_4648.Base32.Hex.isValid("CPNMU==="))
            #expect(RFC_4648.Base32.Hex.isValid("cpnmu==="))
            #expect(RFC_4648.Base32.Hex.isValid("CpNmU==="))
        }

        @Test(
            arguments: [
                "XYZ",
                "ABC!@#",
                "====",
            ]
        )
        func `Invalid Base32-HEX strings`(input: String) {
            #expect(!RFC_4648.Base32.Hex.isValid(input), "\(input) should be invalid Base32-HEX")
        }

        @Test(
            arguments: [
                "",
                "00",
                "ff",
                "FF",
                "deadbeef",
                "DEADBEEF",
                "0xdeadbeef",
                "0xDEADBEEF",
                "0XDEADBEEF",
                "0123456789abcdef",
                "0123456789ABCDEF",
            ]
        )
        func `Valid hexadecimal strings`(input: String) {
            #expect(RFC_4648.Base16.isValid(input), "\(input) should be valid hexadecimal")
        }

        @Test(
            arguments: [
                "ghijk",
                "xyz",
                "fff",
                "!@#$",
            ]
        )
        func `Invalid hexadecimal strings`(input: String) {
            #expect(!RFC_4648.Base16.isValid(input), "\(input) should be invalid hexadecimal")
            #expect(!input.hex.isValid, "\(input) should be invalid hexadecimal")
        }

        @Test
        func `Hexadecimal validation with prefix`() {
            #expect(RFC_4648.Base16.isValid("0xdeadbeef"))
            #expect(RFC_4648.Base16.isValid("0xDEADBEEF"))
            #expect(RFC_4648.Base16.isValid("0XDEADBEEF"))
            #expect(RFC_4648.Base16.isValid("deadbeef"))
        }

        @Test
        func `Validation is efficient for large strings`() {
            let largeValid = String(repeating: "Zm9vYmFy", count: 1000)
            let largeInvalid = String(repeating: "!!!!", count: 1000)

            #expect(RFC_4648.Base64.isValid(largeValid))
            #expect(!RFC_4648.Base64.isValid(largeInvalid))
        }

        @Test
        func `Validation matches decoding for Base64`() {
            let testCases = [
                "Zm9vYmFy",
                "!@#$",
                "Zm9",
                "",
            ]

            for test in testCases {
                let isValid = RFC_4648.Base64.isValid(test)
                let canDecode = [Byte](base64Encoded: test) != nil

                #expect(
                    isValid == canDecode,
                    "Validation and decoding disagree for '\(test)'"
                )
            }
        }

        @Test
        func `Validation matches decoding for Base32`() {
            let testCases = [
                "MZXW6===",
                "189",
                "",
            ]

            for test in testCases {
                let isValid = RFC_4648.Base32.isValid(test)
                let canDecode = [Byte](base32Encoded: test) != nil

                #expect(
                    isValid == canDecode,
                    "Validation and decoding disagree for '\(test)'"
                )
            }
        }

        @Test
        func `Validation matches decoding for hexadecimal`() {
            let testCases = [
                "deadbeef",
                "0xdeadbeef",
                "ghijk",
                "fff",
                "",
            ]

            for test in testCases {
                let isValid = RFC_4648.Base16.isValid(test)
                let canDecode = [Byte](hexEncoded: test) != nil

                #expect(
                    isValid == canDecode,
                    "Validation and decoding disagree for '\(test)'"
                )
            }
        }

        @Test
        func `Empty string validation across all encodings`() {
            let empty = ""

            #expect(RFC_4648.Base64.isValid(empty))
            #expect(RFC_4648.Base64.URL.isValid(empty))
            #expect(RFC_4648.Base32.isValid(empty))
            #expect(RFC_4648.Base32.Hex.isValid(empty))
            #expect(RFC_4648.Base16.isValid(empty))
        }

        @Test
        func `Unicode characters in validation`() {

            #expect(!RFC_4648.Base64.isValid("Zm9v🚀"))
            #expect(!RFC_4648.Base32.isValid("MZXW6😀"))
            #expect(!RFC_4648.Base16.isValid("dead你好"))
        }
    }
}
