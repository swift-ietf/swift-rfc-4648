import Testing

@testable import RFC_4648

@Suite("BinaryInteger Decoding Tests")
struct BinaryIntegerDecodingTests {

    @Test
    func `UInt32 Base64 decoding`() {
        let value = UInt32(123_456)
        let encoded = String.base64(value)

        let decoded = UInt32(base64Encoded: encoded)
        #expect(decoded == value)
    }

    @Test(
        arguments: [
            UInt32(0),
            UInt32(1),
            UInt32(255),
            UInt32(256),
            UInt32(65535),
            UInt32(123_456),
            UInt32(0xDEAD_BEEF),
            UInt32.max,
        ]
    )
    func `UInt32 Base64 round-trip`(value: UInt32) {
        let encoded = String.base64(value)
        let decoded = UInt32(base64Encoded: encoded)

        #expect(decoded == value, "Failed for \(value)")
    }

    @Test(
        arguments: [
            UInt8(0), UInt8(1), UInt8(127), UInt8(128), UInt8(255),
        ]
    )
    func `UInt8 Base64 round-trip`(value: UInt8) {
        let encoded = String.base64(value)
        let decoded = UInt8(base64Encoded: encoded)

        #expect(decoded == value)
    }

    @Test(
        arguments: [
            UInt16(0), UInt16(255), UInt16(256), UInt16(0xABCD), UInt16.max,
        ]
    )
    func `UInt16 Base64 round-trip`(value: UInt16) {
        let encoded = String.base64(value)
        let decoded = UInt16(base64Encoded: encoded)

        #expect(decoded == value)
    }

    @Test(
        arguments: [
            UInt64(0),
            UInt64(UInt32.max),
            UInt64(0x1234_5678_9ABC_DEF0),
            UInt64.max,
        ]
    )
    func `UInt64 Base64 round-trip`(value: UInt64) {
        let encoded = String.base64(value)
        let decoded = UInt64(base64Encoded: encoded)

        #expect(decoded == value)
    }

    @Test
    func `Signed integer Base64 round-trip`() {
        let values: [Int32] = [-1, -128, 0, 127, Int32.max, Int32.min]

        for value in values {
            let encoded = String.base64(value)
            let decoded = Int32(base64Encoded: encoded)

            #expect(decoded == value, "Failed for \(value)")
        }
    }

    @Test
    func `Wrong size Base64 decoding fails`() {
        let uint32Value = UInt32(123_456)
        let encoded = String.base64(uint32Value)

        #expect(UInt8(base64Encoded: encoded) == nil)

        #expect(UInt64(base64Encoded: encoded) == nil)
    }

    @Test(
        arguments: [
            UInt32(0), UInt32(123_456), UInt32(0xDEAD_BEEF), UInt32.max,
        ]
    )
    func `UInt32 Base64URL round-trip`(value: UInt32) {
        let encoded = String.base64.url(value)
        let decoded = UInt32(base64URLEncoded: encoded)

        #expect(decoded == value)
    }

    @Test(
        arguments: [
            UInt32(0), UInt32(123_456), UInt32.max,
        ]
    )
    func `UInt32 Base32 round-trip`(value: UInt32) {
        let encoded = String.base32(value)
        let decoded = UInt32(base32Encoded: encoded)

        #expect(decoded == value)
    }

    @Test
    func `Base32 case insensitive decoding`() {
        let value = UInt32(123_456)
        let upper = String.base32(value)
        let lower = upper.lowercased()

        #expect(UInt32(base32Encoded: upper) == value)
        #expect(UInt32(base32Encoded: lower) == value)
    }

    @Test(
        arguments: [
            UInt32(0), UInt32(123_456), UInt32.max,
        ]
    )
    func `UInt32 Base32-HEX round-trip`(value: UInt32) {
        let encoded = String.base32.hex(value)
        let decoded = UInt32(base32HexEncoded: encoded)

        #expect(decoded == value)
    }

    @Test
    func `UInt32 hexadecimal decoding`() {
        #expect(UInt32(hexEncoded: "deadbeef") == 0xDEAD_BEEF)
        #expect(UInt32(hexEncoded: "0xdeadbeef") == 0xDEAD_BEEF)
        #expect(UInt32(hexEncoded: "0xDEADBEEF") == 0xDEAD_BEEF)
        #expect(UInt32(hexEncoded: "DEADBEEF") == 0xDEAD_BEEF)
    }

    @Test(
        arguments: [
            UInt8(0x00), UInt8(0x0F), UInt8(0xFF), UInt8(0xAB),
        ]
    )
    func `UInt8 hexadecimal round-trip`(value: UInt8) {
        let encoded = String.hex(value, prefix: "")
        let decoded = UInt8(hexEncoded: encoded)

        #expect(decoded == value)
    }

    @Test(
        arguments: [
            UInt16(0x0000), UInt16(0xABCD), UInt16(0xFFFF),
        ]
    )
    func `UInt16 hexadecimal round-trip`(value: UInt16) {
        let encoded = String.hex(value, prefix: "")
        let decoded = UInt16(hexEncoded: encoded)

        #expect(decoded == value)
    }

    @Test(
        arguments: [
            UInt64(0),
            UInt64(0x1234_5678_9ABC_DEF0),
            UInt64.max,
        ]
    )
    func `UInt64 hexadecimal round-trip`(value: UInt64) {
        let encoded = String.hex(value, prefix: "")
        let decoded = UInt64(hexEncoded: encoded)

        #expect(decoded == value)
    }

    @Test
    func `Hexadecimal decoding with prefix`() {
        #expect(UInt32(hexEncoded: "0xDEADBEEF") == 0xDEAD_BEEF)
        #expect(UInt32(hexEncoded: "0XDEADBEEF") == 0xDEAD_BEEF)
        #expect(UInt32(hexEncoded: "deadbeef") == 0xDEAD_BEEF)
    }

    @Test
    func `Invalid Base64 returns nil`() {
        #expect(UInt32(base64Encoded: "invalid!@#$") == nil)
        #expect(UInt32(base64Encoded: "") == nil)
    }

    @Test
    func `Invalid Base32 returns nil`() {
        #expect(UInt32(base32Encoded: "189") == nil)
    }

    @Test
    func `Invalid hexadecimal returns nil`() {
        #expect(UInt32(hexEncoded: "GHIJK") == nil)
        #expect(UInt32(hexEncoded: "xyz") == nil)
    }

    @Test
    func `Zero value across all encodings`() {
        let zero = UInt32(0)

        #expect(UInt32(base64Encoded: String.base64(zero)) == zero)
        #expect(UInt32(base64URLEncoded: String.base64.url(zero)) == zero)
        #expect(UInt32(base32Encoded: String.base32(zero)) == zero)
        #expect(UInt32(base32HexEncoded: String.base32.hex(zero)) == zero)
        #expect(UInt32(hexEncoded: String.hex(zero, prefix: "")) == zero)
    }

    @Test
    func `Maximum value across all encodings`() {
        let max = UInt32.max

        #expect(UInt32(base64Encoded: String.base64(max)) == max)
        #expect(UInt32(base64URLEncoded: String.base64.url(max)) == max)
        #expect(UInt32(base32Encoded: String.base32(max)) == max)
        #expect(UInt32(base32HexEncoded: String.base32.hex(max)) == max)
        #expect(UInt32(hexEncoded: String.hex(max, prefix: "")) == max)
    }

    @Test
    func `All unsigned integer types supported`() {
        _ = UInt8(base64Encoded: String.base64(UInt8(42)))
        _ = UInt16(base64Encoded: String.base64(UInt16(42)))
        _ = UInt32(base64Encoded: String.base64(UInt32(42)))
        _ = UInt64(base64Encoded: String.base64(UInt64(42)))
        _ = UInt(base64Encoded: String.base64(UInt(42)))
    }

    @Test
    func `All signed integer types supported`() {
        _ = Int8(base64Encoded: String.base64(Int8(42)))
        _ = Int16(base64Encoded: String.base64(Int16(42)))
        _ = Int32(base64Encoded: String.base64(Int32(42)))
        _ = Int64(base64Encoded: String.base64(Int64(42)))
        _ = Int(base64Encoded: String.base64(Int(42)))
    }
}
