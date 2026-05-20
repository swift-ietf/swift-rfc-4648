//
//  SpanTests.swift
//  swift-rfc-4648
//
//  Tests for Span-based encoding

import Testing
@testable import RFC_4648

@Suite("Span Encoding")
struct SpanTests {

    // MARK: - Base16 (Hex)

    @Test
    func `Span hex encoding matches Array encoding`() {
        let bytes: [Byte] = [0xDE, 0xAD, 0xBE, 0xEF]
        bytes.withUnsafeBufferPointer { buffer in
            let span = Span(_unsafeElements: buffer)
            #expect(span.hex.encoded() == bytes.hex.encoded())
            #expect(span.hex.encoded(uppercase: true) == bytes.hex.encoded(uppercase: true))
        }
    }

    @Test
    func `Span hex callable syntax`() {
        let bytes: [Byte] = [0xCA, 0xFE]
        bytes.withUnsafeBufferPointer { buffer in
            let span = Span(_unsafeElements: buffer)
            #expect(span.hex() == "cafe")
            #expect(span.hex(uppercase: true) == "CAFE")
        }
    }

    @Test
    func `Empty span hex encoding`() {
        let bytes: [Byte] = []
        bytes.withUnsafeBufferPointer { buffer in
            let span = Span(_unsafeElements: buffer)
            #expect(span.hex.encoded().isEmpty)
        }
    }

    // MARK: - Base64

    @Test
    func `Span base64 encoding matches Array encoding`() {
        let bytes: [Byte] = [72, 101, 108, 108, 111]  // "Hello"
        bytes.withUnsafeBufferPointer { buffer in
            let span = Span(_unsafeElements: buffer)
            #expect(span.base64.encoded() == bytes.base64.encoded())
            #expect(span.base64.encoded(padding: false) == bytes.base64.encoded(padding: false))
        }
    }

    @Test
    func `Span base64 URL encoding matches Array encoding`() {
        let bytes: [Byte] = [0xFB, 0xFF, 0xBF]  // Bytes that produce +/ in standard Base64
        bytes.withUnsafeBufferPointer { buffer in
            let span = Span(_unsafeElements: buffer)
            #expect(span.base64.url.encoded() == bytes.base64.url.encoded())
            #expect(span.base64.url.encoded(padding: true) == bytes.base64.url.encoded(padding: true))
        }
    }

    @Test
    func `Empty span base64 encoding`() {
        let bytes: [Byte] = []
        bytes.withUnsafeBufferPointer { buffer in
            let span = Span(_unsafeElements: buffer)
            #expect(span.base64.encoded().isEmpty)
        }
    }

    // MARK: - Base32

    @Test
    func `Span base32 encoding matches Array encoding`() {
        let bytes: [Byte] = [72, 101, 108, 108, 111]  // "Hello"
        bytes.withUnsafeBufferPointer { buffer in
            let span = Span(_unsafeElements: buffer)
            #expect(span.base32.encoded() == bytes.base32.encoded())
            #expect(span.base32.encoded(padding: false) == bytes.base32.encoded(padding: false))
        }
    }

    @Test
    func `Span base32 hex encoding matches Array encoding`() {
        let bytes: [Byte] = [72, 101, 108, 108, 111]
        bytes.withUnsafeBufferPointer { buffer in
            let span = Span(_unsafeElements: buffer)
            #expect(span.base32.hex.encoded() == bytes.base32.hex.encoded())
            #expect(span.base32.hex.encoded(padding: false) == bytes.base32.hex.encoded(padding: false))
        }
    }

    @Test
    func `Empty span base32 encoding`() {
        let bytes: [Byte] = []
        bytes.withUnsafeBufferPointer { buffer in
            let span = Span(_unsafeElements: buffer)
            #expect(span.base32.encoded().isEmpty)
        }
    }

    // MARK: - Temporary Allocation

    @Test
    func `Span encoding from temporary allocation`() {
        let result = withUnsafeTemporaryAllocation(of: Byte.self, capacity: 4) { buffer in
            buffer[0] = 0xCA
            buffer[1] = 0xFE
            buffer[2] = 0xBA
            buffer[3] = 0xBE
            let span = Span(_unsafeElements: UnsafeBufferPointer(buffer))
            return span.hex.encoded()
        }
        #expect(result == "cafebabe")
    }

    @Test
    func `Span base64 from temporary allocation`() {
        let result = withUnsafeTemporaryAllocation(of: Byte.self, capacity: 3) { buffer in
            buffer[0] = 0x48  // H
            buffer[1] = 0x69  // i
            buffer[2] = 0x21  // !
            let span = Span(_unsafeElements: UnsafeBufferPointer(buffer))
            return span.base64.encoded()
        }
        #expect(result == "SGkh")
    }
}
