//
//  RFC_4648.Base32.Hex.swift
//  swift-rfc-4648
//
//  Base32-HEX encoding per RFC 4648 Section 7

import ASCII_Primitives
public import Binary_Primitives

// MARK: - Base32-HEX Type

extension RFC_4648.Base32 {
    /// Base32-HEX encoding (RFC 4648 Section 7) - Extended Hex Alphabet
    ///
    /// Base32-HEX uses a 32-character alphabet (0-9, A-V) that preserves
    /// lexicographic sort order when the encoded data is sorted as bytes.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Static methods (authoritative)
    /// RFC_4648.Base32.Hex.encode(bytes, into: &buffer)
    /// let decoded = RFC_4648.Base32.Hex.decode("91IMOR3F")
    ///
    /// // Instance methods (convenience) - via base32.hex
    /// bytes.base32.hex.encoded()
    /// "91IMOR3F".base32.hex.decoded()
    /// ```
    public enum Hex {
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

extension RFC_4648.Base32.Hex {
    /// Base32-HEX encoding table (RFC 4648 Section 7)
    public static let encodingTable = RFC_4648.EncodingTable(
        encode: [
            .`0`, .`1`, .`2`, .`3`, .`4`, .`5`, .`6`, .`7`,
            .`8`, .`9`, .A, .B, .C, .D, .E, .F,
            .G, .H, .I, .J, .K, .L, .M, .N,
            .O, .P, .Q, .R, .S, .T, .U, .V,
        ] as [ASCII.Code],
        caseInsensitive: true
    )
}

// MARK: - Static Encode Methods (Authoritative)

extension RFC_4648.Base32.Hex {
    /// Encodes bytes to Base32-HEX into a buffer (streaming)
    @inlinable
    public static func encode<Bytes: Collection, Buffer: RangeReplaceableCollection>(
        _ bytes: Bytes,
        into buffer: inout Buffer,
        padding: Bool = true
    ) where Bytes.Element == Byte, Buffer.Element == ASCII.Code {
        RFC_4648.encodeBase32(bytes, into: &buffer, table: encodingTable.encode, padding: padding)
    }

    /// Encodes bytes to Base32-HEX, returning a new array
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

extension RFC_4648.Base32.Hex {
    /// Decodes a single Base32-HEX character to its 5-bit value (PRIMITIVE)
    ///
    /// - Parameter quintet: ASCII code of Base32-HEX character (0-9, A-V, case-insensitive)
    /// - Returns: 5-bit value (0-31), or nil if invalid. Value is arithmetic-domain
    ///   UInt8 per [API-BYTE-004] Q3 rubric.
    @inlinable
    public static func decode(quintet: ASCII.Code) -> UInt8? {
        encodingTable.decode[Int(quintet.underlying)]
    }

    /// Decodes Base32-HEX ASCII codes into a buffer (streaming, no allocation)
    @inlinable
    @discardableResult
    public static func decode<Bytes: Collection, Buffer: RangeReplaceableCollection>(
        _ bytes: Bytes,
        into buffer: inout Buffer
    ) -> Bool where Bytes.Element == ASCII.Code, Buffer.Element == Byte {
        RFC_4648.decodeBase32(bytes, into: &buffer, decodeTable: encodingTable.decode)
    }

    /// Decodes Base32-HEX encoded ASCII codes to a new byte array
    @inlinable
    public static func decode<Bytes: Collection>(
        _ bytes: Bytes
    ) -> [Byte]? where Bytes.Element == ASCII.Code {
        var result: [Byte] = []
        result.reserveCapacity((bytes.count * 5) / 8)
        guard decode(bytes, into: &result) else { return nil }
        return result
    }

    /// Decodes Base32-HEX encoded string (case-insensitive)
    ///
    /// Lifts `string.utf8` to the `ASCII.Code` substrate at entry.
    /// Returns `nil` if the string contains non-ASCII bytes.
    @inlinable
    public static func decode(_ string: some StringProtocol) -> [Byte]? {
        let codes: [ASCII.Code]
        do {
            codes = try Array<ASCII.Code>(string.utf8)
        } catch {
            return nil
        }
        return decode(codes)
    }

    /// Decodes Base32-HEX to a FixedWidthInteger (PRIMITIVE)
    @inlinable
    public static func decode<Bytes: Collection, T: FixedWidthInteger>(
        _ bytes: Bytes,
        as type: T.Type = T.self
    ) -> T? where Bytes.Element == ASCII.Code {
        RFC_4648.decodeBase32ToInteger(bytes, decodeTable: encodingTable.decode)
    }
}

// MARK: - Instance Methods (Convenience) - Encode (raw bytes IN)

extension RFC_4648.Base32.Hex.Wrapper where Wrapped: Collection, Wrapped.Element == Byte {
    /// Encodes wrapped bytes to Base32-HEX into a buffer
    @inlinable
    public func encode<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer,
        padding: Bool = true
    ) where Buffer.Element == ASCII.Code {
        RFC_4648.Base32.Hex.encode(wrapped, into: &buffer, padding: padding)
    }

    /// Encodes wrapped bytes to Base32-HEX string
    @inlinable
    public func encoded(padding: Bool = true) -> String {
        String(decoding: RFC_4648.Base32.Hex.encode(wrapped, padding: padding), as: UTF8.self)
    }

    /// Encodes wrapped bytes to Base32-HEX string (callable syntax)
    @inlinable
    public func callAsFunction(padding: Bool = true) -> String {
        encoded(padding: padding)
    }
}

// MARK: - Instance Methods (Convenience) - Decode (encoded ASCII codes IN)

extension RFC_4648.Base32.Hex.Wrapper where Wrapped: Collection, Wrapped.Element == ASCII.Code {
    /// Decodes wrapped Base32-HEX-encoded ASCII codes into a buffer
    @inlinable
    @discardableResult
    public func decode<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer
    ) -> Bool where Buffer.Element == Byte {
        RFC_4648.Base32.Hex.decode(wrapped, into: &buffer)
    }

    /// Decodes wrapped Base32-HEX-encoded ASCII codes to raw bytes
    @inlinable
    public func decoded() -> [Byte]? {
        RFC_4648.Base32.Hex.decode(wrapped)
    }

    /// Decodes wrapped Base32-HEX-encoded ASCII codes to a FixedWidthInteger
    @inlinable
    public func decoded<T: FixedWidthInteger>(as type: T.Type = T.self) -> T? {
        RFC_4648.Base32.Hex.decode(wrapped, as: type)
    }
}

// MARK: - Instance Methods (Convenience) - String

extension RFC_4648.Base32.Hex.Wrapper where Wrapped: StringProtocol {
    /// Decodes wrapped Base32-HEX string into a buffer.
    ///
    /// Returns `false` if the string contains non-ASCII bytes.
    @inlinable
    @discardableResult
    public func decode<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer
    ) -> Bool where Buffer.Element == Byte {
        let codes: [ASCII.Code]
        do {
            codes = try Array<ASCII.Code>(wrapped.utf8)
        } catch {
            return false
        }
        return RFC_4648.Base32.Hex.decode(codes, into: &buffer)
    }

    /// Decodes wrapped Base32-HEX string to bytes
    @inlinable
    public func decoded() -> [Byte]? {
        RFC_4648.Base32.Hex.decode(wrapped)
    }

    /// Decodes wrapped Base32-HEX string to a FixedWidthInteger.
    ///
    /// Returns `nil` if the string contains non-ASCII bytes.
    @inlinable
    public func decoded<T: FixedWidthInteger>(as type: T.Type = T.self) -> T? {
        let codes: [ASCII.Code]
        do {
            codes = try Array<ASCII.Code>(wrapped.utf8)
        } catch {
            return nil
        }
        return RFC_4648.Base32.Hex.decode(codes, as: type)
    }
}
