// Collection+RFC4648.swift
// swift-rfc-4648
//
// Collection extensions using RFC_4648 primitives
//
// Array initializers for decoding encoded strings to bytes.
// Byte collection accessors for encoding bytes to strings.
// ASCII.Code collection accessors for decoding encoded codes to bytes.

import ASCII_Primitives

// MARK: - Array Initializers (Decoding)

extension Array where Element == Byte {
    /// Creates an array from a Base64 encoded string (RFC 4648 Section 4)
    ///
    /// Delegates to `RFC_4648.Base64.decode(_:)`.
    @inlinable
    public init?(base64Encoded string: some StringProtocol) {
        guard let decoded = RFC_4648.Base64.decode(string) else { return nil }
        self = decoded
    }

    /// Creates an array from a Base64URL encoded string (RFC 4648 Section 5)
    @inlinable
    public init?(base64URLEncoded string: some StringProtocol) {
        guard let decoded = RFC_4648.Base64.URL.decode(string) else { return nil }
        self = decoded
    }

    /// Creates an array from a Base32 encoded string (RFC 4648 Section 6)
    @inlinable
    public init?(base32Encoded string: some StringProtocol) {
        guard let decoded = RFC_4648.Base32.decode(string) else { return nil }
        self = decoded
    }

    /// Creates an array from a Base32-HEX encoded string (RFC 4648 Section 7)
    @inlinable
    public init?(base32HexEncoded string: some StringProtocol) {
        guard let decoded = RFC_4648.Base32.Hex.decode(string) else { return nil }
        self = decoded
    }

    /// Creates an array from a Base16 (hexadecimal) encoded string (RFC 4648 Section 8)
    @inlinable
    public init?(hexEncoded string: some StringProtocol) {
        guard let decoded = RFC_4648.Base16.decode(string, skipPrefix: true) else { return nil }
        self = decoded
    }
}

// MARK: - Byte Collection Encoding Accessors

extension Collection where Element == Byte {
    /// Access to Base64 instance operations for encoding
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let bytes: [Byte] = [72, 101, 108, 108, 111]
    /// bytes.base64.encoded()       // "SGVsbG8=" (standard Base64)
    /// bytes.base64.url.encoded()   // "SGVsbG8" (URL-safe, no padding)
    /// ```
    @inlinable
    public var base64: RFC_4648.Base64.Wrapper<Self> {
        RFC_4648.Base64.Wrapper(self)
    }

    /// Access to Base32 instance operations for encoding
    @inlinable
    public var base32: RFC_4648.Base32.Wrapper<Self> {
        RFC_4648.Base32.Wrapper(self)
    }

    /// Access to Base16/Hex instance operations for encoding
    @inlinable
    public var hex: RFC_4648.Base16.Wrapper<Self> {
        RFC_4648.Base16.Wrapper(self)
    }
}

// MARK: - ASCII.Code Collection Decoding Accessors

extension Collection where Element == ASCII.Code {
    /// Access to Base64 instance operations for decoding
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let encoded: [ASCII.Code] = Array<ASCII.Code>("SGVsbG8=".utf8)
    /// encoded.base64.decoded()    // [Byte]([72, 101, 108, 108, 111])
    /// ```
    @inlinable
    public var base64: RFC_4648.Base64.Wrapper<Self> {
        RFC_4648.Base64.Wrapper(self)
    }

    /// Access to Base32 instance operations for decoding
    @inlinable
    public var base32: RFC_4648.Base32.Wrapper<Self> {
        RFC_4648.Base32.Wrapper(self)
    }

    /// Access to Base16/Hex instance operations for decoding
    @inlinable
    public var hex: RFC_4648.Base16.Wrapper<Self> {
        RFC_4648.Base16.Wrapper(self)
    }
}
