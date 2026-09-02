import RFC_4648
import Testing

@Suite("BinaryInteger Encoding Tests")
struct BinaryIntegerEncodingTests {

    @Test
    func `Base16: Encode UInt8 values`() {
        #expect(String.hex(UInt8(0)) == "0x00")
        #expect(String.hex(UInt8(255)) == "0xff")
        #expect(String.hex(UInt8(15)) == "0x0f")
        #expect(String.hex(UInt8(16)) == "0x10")
    }

    @Test
    func `Base16: Encode UInt16 values`() {
        #expect(String.hex(UInt16(0)) == "0x0000")
        #expect(String.hex(UInt16(255)) == "0x00ff")
        #expect(String.hex(UInt16(0xABCD)) == "0xabcd")
        #expect(String.hex(UInt16.max) == "0xffff")
    }

    @Test
    func `Base16: Encode UInt32 values`() {
        #expect(String.hex(UInt32(0)) == "0x00000000")
        #expect(String.hex(UInt32(123_456)) == "0x0001e240")
        #expect(String.hex(UInt32(0xDEAD_BEEF)) == "0xdeadbeef")
        #expect(String.hex(UInt32.max) == "0xffffffff")
    }

    @Test
    func `Base16: Encode UInt64 values`() {
        #expect(String.hex(UInt64(0)) == "0x0000000000000000")
        #expect(String.hex(UInt64(0x1234_5678_9ABC_DEF0)) == "0x123456789abcdef0")
        #expect(String.hex(UInt64.max) == "0xffffffffffffffff")
    }

    @Test
    func `Base16: Encode Int values`() {

        #expect(String.hex(Int8(-1)) == "0xff")
        #expect(String.hex(Int8(-128)) == "0x80")
        #expect(String.hex(Int8(127)) == "0x7f")

        #expect(String.hex(Int16(-1)) == "0xffff")
        #expect(String.hex(Int32(-1)) == "0xffffffff")
    }

    @Test
    func `Base16: Custom prefix`() {
        #expect(String.hex(UInt8(255), prefix: "") == "ff")
        #expect(String.hex(UInt8(255), prefix: "0x") == "0xff")
        #expect(String.hex(UInt8(255), prefix: "#") == "#ff")
    }

    @Test
    func `Base16: Uppercase option`() {
        #expect(String.hex(UInt16(0xABCD), uppercase: true) == "0xABCD")
        #expect(String.hex(UInt16(0xABCD), uppercase: false) == "0xabcd")
        #expect(String.hex(UInt8(255), uppercase: true) == "0xFF")
    }

    @Test
    func `Base64: Encode UInt8 values`() {
        #expect(String.base64(UInt8(0)) == "AA==")
        #expect(String.base64(UInt8(255)) == "/w==")
    }

    @Test
    func `Base64: Encode UInt16 values`() {
        #expect(String.base64(UInt16(0)) == "AAA=")
        #expect(String.base64(UInt16(0x0102)) == "AQI=")
    }

    @Test
    func `Base64: Encode UInt32 values`() {
        #expect(String.base64(UInt32(0)) == "AAAAAA==")
        #expect(String.base64(UInt32(123_456)) == "AAHiQA==")
    }

    @Test
    func `Base64: Encode with and without padding`() {
        let value = UInt32(123_456)
        #expect(String.base64(value, padding: true) == "AAHiQA==")
        #expect(String.base64(value, padding: false) == "AAHiQA")
    }

    @Test
    func `Base64: Round-trip UInt values`() {
        let values: [UInt32] = [0, 1, 255, 256, 65535, 123_456, UInt32.max]

        for value in values {
            let encoded = String.base64(value)
            let decoded = [Byte](base64Encoded: encoded)

            guard let bytes = decoded else {
                Issue.record("Failed to decode: \(encoded)")
                continue
            }

            let reconstructed = UInt32(
                bigEndian: bytes.withUnsafeBytes { $0.load(as: UInt32.self) }
            )

            #expect(reconstructed == value, "Round-trip failed for \(value)")
        }
    }

    @Test
    func `Base64URL: Encode UInt values`() {

        #expect(String.base64.url(UInt32(0)) == "AAAAAA")
        #expect(String.base64.url(UInt32(123_456)) == "AAHiQA")
    }

    @Test
    func `Base64URL: Padding control`() {
        let value = UInt32(123_456)
        #expect(String.base64.url(value, padding: false) == "AAHiQA")
        #expect(String.base64.url(value, padding: true) == "AAHiQA==")
    }

    @Test
    func `Base64URL: Different from Base64`() {

        let value = UInt32(0x00FF_FFFF)

        let base64 = String.base64(value, padding: false)
        let base64URL = String.base64.url(value, padding: false)

        #expect(base64 == "AP__/w" || base64 != base64URL)
    }

    @Test
    func `Base32: Encode UInt values`() {

        #expect(String.base32(UInt32(0)) == "AAAAAAA=")

        #expect(String.base32(UInt32(123_456)) == "AAA6EQA=")
    }

    @Test
    func `Base32: Padding control`() {
        let value = UInt32(123_456)

        #expect(String.base32(value, padding: true) == "AAA6EQA=")
        #expect(String.base32(value, padding: false) == "AAA6EQA")
    }

    @Test
    func `Base32: Round-trip`() {
        let value = UInt32(123_456)
        let encoded = String.base32(value)
        let decoded = [Byte](base32Encoded: encoded)

        #expect(decoded != nil, "Decoding should succeed")
        guard let bytes = decoded else { return }

        let reconstructed = UInt32(bigEndian: bytes.withUnsafeBytes { $0.load(as: UInt32.self) })

        #expect(reconstructed == value)
    }

    @Test
    func `Base32-HEX: Encode UInt values`() {

        #expect(String.base32.hex(UInt32(0)) == "0000000=")

        #expect(String.base32.hex(UInt32(123_456)) == "000U4G0=")
    }

    @Test
    func `Base32-HEX: Padding control`() {
        let value = UInt32(123_456)

        #expect(String.base32.hex(value, padding: true) == "000U4G0=")
        #expect(String.base32.hex(value, padding: false) == "000U4G0")
    }

    @Test
    func `Base32-HEX: Different from Base32`() {

        let value = UInt32(123_456)

        let base32 = String.base32(value, padding: false)
        let base32Hex = String.base32.hex(value, padding: false)

        #expect(base32 != base32Hex, "Base32 and Base32-HEX should differ")

        #expect(base32 == "AAA6EQA")
        #expect(base32Hex == "000U4G0")
    }

    @Test
    func `Big-endian byte order across all encodings`() {
        let value = UInt32(0x1234_5678)

        let expectedBytes: [Byte] = ([0x12, 0x34, 0x56, 0x78] as [UInt8]).map(Byte.init(bitPattern:))

        let hex = String.hex(value, prefix: "")
        #expect(hex == "12345678")

        let hexDecoded = [Byte](hexEncoded: hex)
        #expect(hexDecoded == expectedBytes)

        let base64FromBytes = String.base64(expectedBytes)
        let base64FromInt = String.base64(value)
        #expect(base64FromInt == base64FromBytes)
    }

    @Test
    func `Zero value across all encodings`() {
        #expect(String.hex(UInt8(0)) == "0x00")
        #expect(String.base64(UInt8(0)) == "AA==")
        #expect(String.base64.url(UInt8(0)) == "AA")
        #expect(String.base32(UInt8(0)) == "AA======")
        #expect(String.base32.hex(UInt8(0)) == "00======")
    }

    @Test
    func `Maximum values across all encodings`() {

        _ = String.hex(UInt8.max)
        _ = String.hex(UInt16.max)
        _ = String.hex(UInt32.max)
        _ = String.hex(UInt64.max)

        _ = String.base64(UInt8.max)
        _ = String.base64(UInt16.max)
        _ = String.base64(UInt32.max)

        _ = String.base32(UInt8.max)
        _ = String.base32(UInt16.max)

        _ = String.base32.hex(UInt8.max)
        _ = String.base32.hex(UInt16.max)
    }

    @Test
    func `All BinaryInteger types supported`() {

        _ = String.hex(UInt8(42))
        _ = String.hex(UInt16(42))
        _ = String.hex(UInt32(42))
        _ = String.hex(UInt64(42))
        _ = String.hex(UInt(42))

        _ = String.hex(Int8(42))
        _ = String.hex(Int16(42))
        _ = String.hex(Int32(42))
        _ = String.hex(Int64(42))
        _ = String.hex(Int(42))

        _ = String.base64(UInt(42))
        _ = String.base64.url(Int32(42))
        _ = String.base32(UInt16(42))
        _ = String.base32.hex(Int64(42))
    }
}
