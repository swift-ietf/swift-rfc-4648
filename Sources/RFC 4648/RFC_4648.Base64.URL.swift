//
//  RFC_4648.Base64.URL.swift
//  swift-rfc-4648
//
//  Base64URL encoding per RFC 4648 Section 5

import ASCII_Primitives
public import Binary_Primitives

// MARK: - Base64URL Type

extension RFC_4648.Base64 {
    /// Base64URL encoding (RFC 4648 Section 5) - URL and filename safe
    ///
    /// Base64URL uses a modified alphabet that replaces `+` with `-` and `/` with `_`,
    /// making it safe for use in URLs and filenames. Padding is optional (default: off).
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Static methods (authoritative)
    /// RFC_4648.Base64.URL.encode(bytes, into: &buffer)
    /// let decoded = RFC_4648.Base64.URL.decode("SGVsbG8")
    ///
    /// // Instance methods (convenience) - via base64.url
    /// bytes.base64.url.encoded()
    /// "SGVsbG8".base64.url.decoded()
    /// ```
    public enum URL {
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

extension RFC_4648.Base64.URL {
    /// Base64URL encoding table (RFC 4648 Section 5)
    public static let encodingTable = RFC_4648.EncodingTable(
        encode: Array<ASCII.Code>("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_".utf8)
    )
}

// MARK: - Static Encode Methods (Authoritative)

extension RFC_4648.Base64.URL {
    /// Encodes bytes to Base64URL into a buffer (streaming)
    ///
    /// Base64URL encodes 3 bytes into 4 characters.
    ///
    /// - Parameters:
    ///   - bytes: The bytes to encode
    ///   - buffer: The buffer to append Base64URL characters to
    ///   - padding: Whether to include padding characters (default: false per RFC 7515)
    ///
    /// ## Example
    ///
    /// ```swift
    /// var buffer: [ASCII.Code] = []
    /// RFC_4648.Base64.URL.encode([Byte](Array("Hello".utf8)), into: &buffer)
    /// // buffer contains "SGVsbG8" as ASCII codes (no padding)
    /// ```
    @inlinable
    public static func encode<Bytes: Collection, Buffer: RangeReplaceableCollection>(
        _ bytes: Bytes,
        into buffer: inout Buffer,
        padding: Bool = false
    ) where Bytes.Element == Byte, Buffer.Element == ASCII.Code {
        RFC_4648.encodeBase64(bytes, into: &buffer, table: encodingTable.encode, padding: padding)
    }

    /// Encodes bytes to Base64URL, returning a new array
    ///
    /// - Parameters:
    ///   - bytes: The bytes to encode
    ///   - padding: Whether to include padding characters (default: false per RFC 7515)
    /// - Returns: Base64URL encoded ASCII codes
    @inlinable
    public static func encode<Bytes: Collection>(
        _ bytes: Bytes,
        padding: Bool = false
    ) -> [ASCII.Code] where Bytes.Element == Byte {
        var result: [ASCII.Code] = []
        result.reserveCapacity(((bytes.count + 2) / 3) * 4)
        encode(bytes, into: &result, padding: padding)
        return result
    }
}

// MARK: - Static Decode Methods (Authoritative)

extension RFC_4648.Base64.URL {
    /// Decodes a single Base64URL character to its 6-bit value (PRIMITIVE)
    ///
    /// - Parameter sextet: ASCII code of Base64URL character
    /// - Returns: 6-bit value (0-63), or nil if invalid. Value is arithmetic-domain
    ///   UInt8 per [API-BYTE-004] Q3 rubric.
    ///
    /// ## Example
    ///
    /// ```swift
    /// RFC_4648.Base64.URL.decode(sextet: .A)              // 0
    /// RFC_4648.Base64.URL.decode(sextet: .underline)      // 63
    /// RFC_4648.Base64.URL.decode(sextet: .slash)          // nil (not URL-safe)
    /// ```
    @inlinable
    public static func decode(sextet: ASCII.Code) -> UInt8? {
        encodingTable.decode[Int(sextet.underlying)]
    }

    /// Decodes Base64URL ASCII codes into a buffer (streaming, no allocation)
    ///
    /// Supports both padded and unpadded input.
    ///
    /// - Parameters:
    ///   - bytes: Base64URL encoded ASCII codes
    ///   - buffer: The buffer to append decoded bytes to
    /// - Returns: `true` if decoding succeeded, `false` if invalid input
    ///
    /// ## Example
    ///
    /// ```swift
    /// var buffer: [Byte] = []
    /// let success = RFC_4648.Base64.URL.decode(Array<ASCII.Code>("SGVsbG8".utf8), into: &buffer)
    /// // buffer == [72, 101, 108, 108, 111] ("Hello")
    /// ```
    @inlinable
    @discardableResult
    public static func decode<Bytes: Collection, Buffer: RangeReplaceableCollection>(
        _ bytes: Bytes,
        into buffer: inout Buffer
    ) -> Bool where Bytes.Element == ASCII.Code, Buffer.Element == Byte {
        RFC_4648.decodeBase64(bytes, into: &buffer, decodeTable: encodingTable.decode, requirePadding: false)
    }

    /// Decodes Base64URL encoded ASCII codes to a new byte array
    ///
    /// - Parameter bytes: Base64URL encoded ASCII codes
    /// - Returns: Decoded bytes, or nil if invalid
    ///
    /// ## Example
    ///
    /// ```swift
    /// let decoded = RFC_4648.Base64.URL.decode(Array<ASCII.Code>("SGVsbG8".utf8))
    /// // decoded == [72, 101, 108, 108, 111] ("Hello")
    /// ```
    @inlinable
    public static func decode<Bytes: Collection>(
        _ bytes: Bytes
    ) -> [Byte]? where Bytes.Element == ASCII.Code {
        var result: [Byte] = []
        result.reserveCapacity((bytes.count * 3) / 4)
        guard decode(bytes, into: &result) else { return nil }
        return result
    }

    /// Decodes Base64URL encoded string
    ///
    /// Lifts `string.utf8` to the `ASCII.Code` substrate at entry.
    ///
    /// - Parameter string: Base64URL encoded string
    /// - Returns: Decoded bytes, or nil if invalid
    ///
    /// ## Example
    ///
    /// ```swift
    /// let decoded = RFC_4648.Base64.URL.decode("SGVsbG8")
    /// // decoded == [72, 101, 108, 108, 111] ("Hello")
    /// ```
    @inlinable
    public static func decode(_ string: some StringProtocol) -> [Byte]? {
        decode(Array<ASCII.Code>(string.utf8))
    }

    /// Decodes Base64URL to a FixedWidthInteger (PRIMITIVE)
    ///
    /// Decodes Base64URL ASCII codes directly to an integer value without intermediate array allocation.
    ///
    /// - Parameter bytes: Base64URL encoded ASCII codes
    /// - Returns: Decoded integer value, or nil if invalid or overflow
    ///
    /// ## Example
    ///
    /// ```swift
    /// let value: UInt32? = RFC_4648.Base64.URL.decode(Array<ASCII.Code>("AQIDBA".utf8))
    /// // value == 0x01020304
    /// ```
    @inlinable
    public static func decode<Bytes: Collection, T: FixedWidthInteger>(
        _ bytes: Bytes,
        as type: T.Type = T.self
    ) -> T? where Bytes.Element == ASCII.Code {
        RFC_4648.decodeBase64ToInteger(bytes, decodeTable: encodingTable.decode)
    }
}

// MARK: - Instance Methods (Convenience) - Encode (raw bytes IN)

extension RFC_4648.Base64.URL.Wrapper where Wrapped: Collection, Wrapped.Element == Byte {
    /// Encodes wrapped bytes to Base64URL into a buffer
    @inlinable
    public func encode<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer,
        padding: Bool = false
    ) where Buffer.Element == ASCII.Code {
        RFC_4648.Base64.URL.encode(wrapped, into: &buffer, padding: padding)
    }

    /// Encodes wrapped bytes to Base64URL string
    @inlinable
    public func encoded(padding: Bool = false) -> String {
        String(decoding: RFC_4648.Base64.URL.encode(wrapped, padding: padding), as: UTF8.self)
    }

    /// Encodes wrapped bytes to Base64URL string (callable syntax)
    @inlinable
    public func callAsFunction(padding: Bool = false) -> String {
        encoded(padding: padding)
    }
}

// MARK: - Instance Methods (Convenience) - Decode (encoded ASCII codes IN)

extension RFC_4648.Base64.URL.Wrapper where Wrapped: Collection, Wrapped.Element == ASCII.Code {
    /// Decodes wrapped Base64URL-encoded ASCII codes into a buffer
    @inlinable
    @discardableResult
    public func decode<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer
    ) -> Bool where Buffer.Element == Byte {
        RFC_4648.Base64.URL.decode(wrapped, into: &buffer)
    }

    /// Decodes wrapped Base64URL-encoded ASCII codes to raw bytes
    @inlinable
    public func decoded() -> [Byte]? {
        RFC_4648.Base64.URL.decode(wrapped)
    }

    /// Decodes wrapped Base64URL-encoded ASCII codes to a FixedWidthInteger
    @inlinable
    public func decoded<T: FixedWidthInteger>(as type: T.Type = T.self) -> T? {
        RFC_4648.Base64.URL.decode(wrapped, as: type)
    }
}

// MARK: - Instance Methods (Convenience) - String

extension RFC_4648.Base64.URL.Wrapper where Wrapped: StringProtocol {
    /// Decodes wrapped Base64URL string into a buffer
    @inlinable
    @discardableResult
    public func decode<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer
    ) -> Bool where Buffer.Element == Byte {
        RFC_4648.Base64.URL.decode(Array<ASCII.Code>(wrapped.utf8), into: &buffer)
    }

    /// Decodes wrapped Base64URL string to bytes
    @inlinable
    public func decoded() -> [Byte]? {
        RFC_4648.Base64.URL.decode(wrapped)
    }

    /// Decodes wrapped Base64URL string to a FixedWidthInteger
    @inlinable
    public func decoded<T: FixedWidthInteger>(as type: T.Type = T.self) -> T? {
        RFC_4648.Base64.URL.decode(Array<ASCII.Code>(wrapped.utf8), as: type)
    }
}
