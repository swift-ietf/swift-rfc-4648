//
//  RFC_4648.Base32.swift
//  swift-rfc-4648
//
//  Base32 encoding per RFC 4648 Section 6

import ASCII_Primitives
public import Binary_Primitives

// MARK: - Base32 Type

extension RFC_4648 {
    /// Base32 encoding (RFC 4648 Section 6) - Case-insensitive, human-friendly
    ///
    /// Base32 uses a 32-character alphabet (A-Z, 2-7) designed to be:
    /// - Case-insensitive (avoids confusion between similar letters)
    /// - Human-friendly (excludes 0, 1, 8, 9 which resemble letters)
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Static methods (authoritative)
    /// RFC_4648.Base32.encode(bytes, into: &buffer)
    /// let decoded = RFC_4648.Base32.decode("JBSWY3DPEHPK3PXP")
    ///
    /// // Instance methods (convenience)
    /// bytes.base32.encoded()
    /// "JBSWY3DPEHPK3PXP".base32.decoded()
    /// ```
    public enum Base32 {
        /// Wrapper for instance-based convenience methods
        public struct Wrapper<Wrapped> {
            public let wrapped: Wrapped

            @inlinable
            public init(_ wrapped: Wrapped) {
                self.wrapped = wrapped
            }
        }
    }
}

// MARK: - Encoding Table

extension RFC_4648.Base32 {
    /// Base32 encoding table (RFC 4648 Section 6)
    public static let encodingTable = RFC_4648.EncodingTable(
        encode: Array<ASCII.Code>("ABCDEFGHIJKLMNOPQRSTUVWXYZ234567".utf8),
        caseInsensitive: true
    )
}

// MARK: - Static Encode Methods (Authoritative)

extension RFC_4648.Base32 {
    /// Encodes bytes to Base32 into a buffer (streaming)
    ///
    /// Base32 encodes 5 bytes into 8 characters.
    @inlinable
    public static func encode<Bytes: Collection, Buffer: RangeReplaceableCollection>(
        _ bytes: Bytes,
        into buffer: inout Buffer,
        padding: Bool = true
    ) where Bytes.Element == Byte, Buffer.Element == ASCII.Code {
        RFC_4648.encodeBase32(bytes, into: &buffer, table: encodingTable.encode, padding: padding)
    }

    /// Encodes bytes to Base32, returning a new array
    @inlinable
    public static func encode<Bytes: Collection>(
        _ bytes: Bytes,
        padding: Bool = true
    ) -> [ASCII.Code] where Bytes.Element == Byte {
        var result: [ASCII.Code] = []
        result.reserveCapacity(((bytes.count + 4) / 5) * 8)
        encode(bytes, into: &result, padding: padding)
        return result
    }
}

// MARK: - Static Decode Methods (Authoritative)

extension RFC_4648.Base32 {
    /// Decodes a single Base32 character to its 5-bit value (PRIMITIVE)
    ///
    /// - Parameter quintet: ASCII code of Base32 character (A-Z, 2-7, case-insensitive)
    /// - Returns: 5-bit value (0-31), or nil if invalid. Value is arithmetic-domain
    ///   UInt8 per [API-BYTE-004] Q3 rubric.
    @inlinable
    public static func decode(quintet: ASCII.Code) -> UInt8? {
        encodingTable.decode[Int(quintet.underlying)]
    }

    /// Decodes Base32 ASCII codes into a buffer (streaming, no allocation)
    @inlinable
    @discardableResult
    public static func decode<Bytes: Collection, Buffer: RangeReplaceableCollection>(
        _ bytes: Bytes,
        into buffer: inout Buffer
    ) -> Bool where Bytes.Element == ASCII.Code, Buffer.Element == Byte {
        RFC_4648.decodeBase32(bytes, into: &buffer, decodeTable: encodingTable.decode)
    }

    /// Decodes Base32 encoded ASCII codes to a new byte array
    @inlinable
    public static func decode<Bytes: Collection>(
        _ bytes: Bytes
    ) -> [Byte]? where Bytes.Element == ASCII.Code {
        var result: [Byte] = []
        result.reserveCapacity((bytes.count * 5) / 8)
        guard decode(bytes, into: &result) else { return nil }
        return result
    }

    /// Decodes Base32 encoded string (case-insensitive)
    ///
    /// Lifts `string.utf8` to the `ASCII.Code` substrate at entry.
    @inlinable
    public static func decode(_ string: some StringProtocol) -> [Byte]? {
        decode(Array<ASCII.Code>(string.utf8))
    }

    /// Decodes Base32 to a FixedWidthInteger (PRIMITIVE)
    @inlinable
    public static func decode<Bytes: Collection, T: FixedWidthInteger>(
        _ bytes: Bytes,
        as type: T.Type = T.self
    ) -> T? where Bytes.Element == ASCII.Code {
        RFC_4648.decodeBase32ToInteger(bytes, decodeTable: encodingTable.decode)
    }
}

// MARK: - Hex Accessor

extension RFC_4648.Base32.Wrapper {
    /// Access to Base32-HEX instance operations
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let bytes: [Byte] = [72, 101, 108, 108, 111]
    /// bytes.base32.hex.encoded()  // "91IMOR3F"
    ///
    /// let encoded = "91IMOR3F"
    /// encoded.base32.hex.decoded()  // [72, 101, 108, 108, 111]
    /// ```
    @inlinable
    public var hex: RFC_4648.Base32.Hex.Wrapper<Wrapped> {
        RFC_4648.Base32.Hex.Wrapper(wrapped)
    }
}

// MARK: - Instance Methods (Convenience) - Encode (raw bytes IN)

extension RFC_4648.Base32.Wrapper where Wrapped: Collection, Wrapped.Element == Byte {
    /// Encodes wrapped bytes to Base32 into a buffer
    @inlinable
    public func encode<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer,
        padding: Bool = true
    ) where Buffer.Element == ASCII.Code {
        RFC_4648.Base32.encode(wrapped, into: &buffer, padding: padding)
    }

    /// Encodes wrapped bytes to Base32 string
    @inlinable
    public func encoded(padding: Bool = true) -> String {
        String(decoding: RFC_4648.Base32.encode(wrapped, padding: padding), as: UTF8.self)
    }

    /// Encodes wrapped bytes to Base32 string (callable syntax)
    @inlinable
    public func callAsFunction(padding: Bool = true) -> String {
        encoded(padding: padding)
    }
}

// MARK: - Instance Methods (Convenience) - Decode (encoded ASCII codes IN)

extension RFC_4648.Base32.Wrapper where Wrapped: Collection, Wrapped.Element == ASCII.Code {
    /// Decodes wrapped Base32-encoded ASCII codes into a buffer
    @inlinable
    @discardableResult
    public func decode<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer
    ) -> Bool where Buffer.Element == Byte {
        RFC_4648.Base32.decode(wrapped, into: &buffer)
    }

    /// Decodes wrapped Base32-encoded ASCII codes to raw bytes
    @inlinable
    public func decoded() -> [Byte]? {
        RFC_4648.Base32.decode(wrapped)
    }

    /// Decodes wrapped Base32-encoded ASCII codes to a FixedWidthInteger
    @inlinable
    public func decoded<T: FixedWidthInteger>(as type: T.Type = T.self) -> T? {
        RFC_4648.Base32.decode(wrapped, as: type)
    }
}

// MARK: - Instance Methods (Convenience) - String

extension RFC_4648.Base32.Wrapper where Wrapped: StringProtocol {
    /// Decodes wrapped Base32 string into a buffer
    @inlinable
    @discardableResult
    public func decode<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer
    ) -> Bool where Buffer.Element == Byte {
        RFC_4648.Base32.decode(Array<ASCII.Code>(wrapped.utf8), into: &buffer)
    }

    /// Decodes wrapped Base32 string to bytes
    @inlinable
    public func decoded() -> [Byte]? {
        RFC_4648.Base32.decode(wrapped)
    }

    /// Decodes wrapped Base32 string to a FixedWidthInteger
    @inlinable
    public func decoded<T: FixedWidthInteger>(as type: T.Type = T.self) -> T? {
        RFC_4648.Base32.decode(Array<ASCII.Code>(wrapped.utf8), as: type)
    }
}
