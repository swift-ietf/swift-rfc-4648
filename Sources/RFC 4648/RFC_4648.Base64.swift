//
//  RFC_4648.Base64.swift
//  swift-rfc-4648
//
//  Base64 encoding per RFC 4648 Section 4

import ASCII_Primitives
public import Binary_Primitives

// MARK: - Base64 Type

extension RFC_4648 {
    /// Base64 encoding (RFC 4648 Section 4)
    ///
    /// Base64 encodes binary data using a 64-character alphabet (A-Z, a-z, 0-9, +, /).
    /// Each 3 bytes of input produce 4 characters of output.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Static methods (authoritative)
    /// RFC_4648.Base64.encode(bytes, into: &buffer)
    /// let decoded = RFC_4648.Base64.decode("SGVsbG8=")
    ///
    /// // Instance methods (convenience)
    /// bytes.base64.encoded()
    /// "SGVsbG8=".base64.decoded()
    ///
    /// // URL-safe variant via .url accessor
    /// bytes.base64.url.encoded()
    /// ```
    public enum Base64 {
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

extension RFC_4648.Base64 {
    /// Base64 encoding table (RFC 4648 Section 4)
    public static let encodingTable = RFC_4648.EncodingTable(
        encode: [
            .A, .B, .C, .D, .E, .F, .G, .H,
            .I, .J, .K, .L, .M, .N, .O, .P,
            .Q, .R, .S, .T, .U, .V, .W, .X,
            .Y, .Z, .a, .b, .c, .d, .e, .f,
            .g, .h, .i, .j, .k, .l, .m, .n,
            .o, .p, .q, .r, .s, .t, .u, .v,
            .w, .x, .y, .z, .`0`, .`1`, .`2`, .`3`,
            .`4`, .`5`, .`6`, .`7`, .`8`, .`9`, .plus, .slash,
        ] as [ASCII.Code]
    )
}

// MARK: - Static Encode Methods (Authoritative)

extension RFC_4648.Base64 {
    /// Encodes bytes to Base64 into a buffer (streaming)
    ///
    /// Base64 encodes 3 bytes into 4 characters.
    ///
    /// - Parameters:
    ///   - bytes: The bytes to encode
    ///   - buffer: The buffer to append Base64 characters to
    ///   - padding: Whether to include padding characters (default: true)
    ///
    /// ## Example
    ///
    /// ```swift
    /// var buffer: [ASCII.Code] = []
    /// RFC_4648.Base64.encode([Byte](Array("Hello".utf8)), into: &buffer)
    /// // buffer contains "SGVsbG8=" as ASCII codes
    /// ```
    @inlinable
    public static func encode<Bytes: Collection, Buffer: RangeReplaceableCollection>(
        _ bytes: Bytes,
        into buffer: inout Buffer,
        padding: Bool = true
    ) where Bytes.Element == Byte, Buffer.Element == ASCII.Code {
        RFC_4648.encodeBase64(bytes, into: &buffer, table: encodingTable.encode, padding: padding)
    }

    /// Encodes bytes to Base64, returning a new array
    ///
    /// - Parameters:
    ///   - bytes: The bytes to encode
    ///   - padding: Whether to include padding characters (default: true)
    /// - Returns: Base64 encoded ASCII codes
    @inlinable
    public static func encode<Bytes: Collection>(
        _ bytes: Bytes,
        padding: Bool = true
    ) -> [ASCII.Code] where Bytes.Element == Byte {
        var result: [ASCII.Code] = []
        result.reserveCapacity(((bytes.count + 2) / 3) * 4)
        encode(bytes, into: &result, padding: padding)
        return result
    }
}

// MARK: - Static Decode Methods (Authoritative)

extension RFC_4648.Base64 {
    /// Decodes a single Base64 character to its 6-bit value (PRIMITIVE)
    ///
    /// - Parameter sextet: ASCII code of Base64 character
    /// - Returns: 6-bit value (0-63), or nil if invalid. Value is arithmetic-domain
    ///   UInt8 per [API-BYTE-004] Q3 rubric.
    ///
    /// ## Example
    ///
    /// ```swift
    /// RFC_4648.Base64.decode(sextet: .A)              // 0
    /// RFC_4648.Base64.decode(sextet: .slash)          // 63
    /// RFC_4648.Base64.decode(sextet: .commercialAt)   // nil (invalid)
    /// ```
    @inlinable
    public static func decode(sextet: ASCII.Code) -> UInt8? {
        encodingTable.decode[Int(sextet.underlying)]
    }

    /// Decodes Base64 ASCII codes into a buffer (streaming, no allocation)
    ///
    /// Standard Base64 requires proper padding (groups of 4 characters).
    ///
    /// - Parameters:
    ///   - bytes: Base64 encoded ASCII codes
    ///   - buffer: The buffer to append decoded bytes to
    ///   - strictness: Whitespace/non-canonical-padding posture (default ``RFC_4648/Strictness/lenient``)
    /// - Returns: `true` if decoding succeeded, `false` if invalid input
    ///
    /// ## Example
    ///
    /// ```swift
    /// var buffer: [Byte] = []
    /// let success = RFC_4648.Base64.decode([ASCII.Code]("SGVsbG8=".utf8), into: &buffer)
    /// // buffer == [72, 101, 108, 108, 111] ("Hello")
    /// ```
    @inlinable
    @discardableResult
    public static func decode<Bytes: Collection, Buffer: RangeReplaceableCollection>(
        _ bytes: Bytes,
        into buffer: inout Buffer,
        strictness: RFC_4648.Strictness = .lenient
    ) -> Bool where Bytes.Element == ASCII.Code, Buffer.Element == Byte {
        RFC_4648.decodeBase64(
            bytes, into: &buffer, decodeTable: encodingTable.decode, requirePadding: true, strictness: strictness)
    }

    /// Decodes Base64 encoded ASCII codes to a new byte array
    ///
    /// - Parameters:
    ///   - bytes: Base64 encoded ASCII codes
    ///   - strictness: Whitespace/non-canonical-padding posture (default ``RFC_4648/Strictness/lenient``)
    /// - Returns: Decoded bytes, or nil if invalid
    ///
    /// ## Example
    ///
    /// ```swift
    /// let decoded = RFC_4648.Base64.decode([ASCII.Code]("SGVsbG8=".utf8))
    /// // decoded == [72, 101, 108, 108, 111] ("Hello")
    /// ```
    @inlinable
    public static func decode<Bytes: Collection>(
        _ bytes: Bytes,
        strictness: RFC_4648.Strictness = .lenient
    ) -> [Byte]? where Bytes.Element == ASCII.Code {
        var result: [Byte] = []
        result.reserveCapacity((bytes.count * 3) / 4)
        guard decode(bytes, into: &result, strictness: strictness) else { return nil }
        return result
    }

    /// Decodes Base64 encoded string
    ///
    /// Convenience overload that delegates to the ASCII-code-based version,
    /// lifting `string.utf8` to the `ASCII.Code` substrate at entry.
    ///
    /// - Parameters:
    ///   - string: Base64 encoded string
    ///   - strictness: Whitespace/non-canonical-padding posture (default ``RFC_4648/Strictness/lenient``)
    /// - Returns: Decoded bytes, or nil if invalid
    ///
    /// ## Example
    ///
    /// ```swift
    /// let decoded = RFC_4648.Base64.decode("SGVsbG8=")
    /// // decoded == [72, 101, 108, 108, 111] ("Hello")
    /// ```
    @inlinable
    public static func decode(_ string: some StringProtocol, strictness: RFC_4648.Strictness = .lenient) -> [Byte]? {
        let codes: [ASCII.Code]
        do throws(ASCII.Code.Error) {
            codes = try [ASCII.Code](string.utf8)
        } catch {
            return nil
        }
        return decode(codes, strictness: strictness)
    }

    /// Decodes Base64 to a FixedWidthInteger (PRIMITIVE)
    ///
    /// Decodes Base64 ASCII codes directly to an integer value without intermediate array allocation.
    ///
    /// - Parameter bytes: Base64 encoded ASCII codes
    /// - Returns: Decoded integer value, or nil if invalid or overflow
    ///
    /// ## Example
    ///
    /// ```swift
    /// let value: UInt32? = RFC_4648.Base64.decode([ASCII.Code]("AQIDBA==".utf8))
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

// MARK: - URL Accessor

extension RFC_4648.Base64.Wrapper {
    /// Access to Base64URL instance operations
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let bytes: [Byte] = [72, 101, 108, 108, 111]
    /// bytes.base64.url.encoded()  // "SGVsbG8" (no padding by default)
    ///
    /// let encoded = "SGVsbG8"
    /// encoded.base64.url.decoded()  // [72, 101, 108, 108, 111]
    /// ```
    @inlinable
    public var url: RFC_4648.Base64.URL.Wrapper<Wrapped> {
        RFC_4648.Base64.URL.Wrapper(wrapped)
    }
}

// MARK: - Instance Methods (Convenience) - Encode (raw bytes IN)

extension RFC_4648.Base64.Wrapper where Wrapped: Collection, Wrapped.Element == Byte {
    /// Encodes wrapped bytes to Base64 into a buffer
    ///
    /// Delegates to static `RFC_4648.Base64.encode(_:into:padding:)`.
    @inlinable
    public func encode<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer,
        padding: Bool = true
    ) where Buffer.Element == ASCII.Code {
        RFC_4648.Base64.encode(wrapped, into: &buffer, padding: padding)
    }

    /// Encodes wrapped bytes to Base64 string
    ///
    /// Delegates to static `RFC_4648.Base64.encode(_:padding:)`.
    @inlinable
    public func encoded(padding: Bool = true) -> String {
        String(decoding: RFC_4648.Base64.encode(wrapped, padding: padding), as: UTF8.self)
    }

    /// Encodes wrapped bytes to Base64 string (callable syntax)
    @inlinable
    public func callAsFunction(padding: Bool = true) -> String {
        encoded(padding: padding)
    }
}

// MARK: - Instance Methods (Convenience) - Decode (encoded ASCII codes IN)

extension RFC_4648.Base64.Wrapper where Wrapped: Collection, Wrapped.Element == ASCII.Code {
    /// Decodes wrapped Base64-encoded ASCII codes into a buffer
    ///
    /// Delegates to static `RFC_4648.Base64.decode(_:into:strictness:)`.
    @inlinable
    @discardableResult
    public func decode<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer,
        strictness: RFC_4648.Strictness = .lenient
    ) -> Bool where Buffer.Element == Byte {
        RFC_4648.Base64.decode(wrapped, into: &buffer, strictness: strictness)
    }

    /// Decodes wrapped Base64-encoded ASCII codes to raw bytes
    ///
    /// Delegates to static `RFC_4648.Base64.decode(_:strictness:)`.
    @inlinable
    public func decoded(strictness: RFC_4648.Strictness = .lenient) -> [Byte]? {
        RFC_4648.Base64.decode(wrapped, strictness: strictness)
    }

    /// Decodes wrapped Base64-encoded ASCII codes to a FixedWidthInteger
    ///
    /// Delegates to static `RFC_4648.Base64.decode(_:as:)`.
    @inlinable
    public func decoded<T: FixedWidthInteger>(as type: T.Type = T.self) -> T? {
        RFC_4648.Base64.decode(wrapped, as: type)
    }
}

// MARK: - Instance Methods (Convenience) - String

extension RFC_4648.Base64.Wrapper where Wrapped: StringProtocol {
    /// Decodes wrapped Base64 string into a buffer
    ///
    /// Lifts `wrapped.utf8` to the `ASCII.Code` substrate at entry.
    /// Returns `false` if the string contains non-ASCII bytes.
    /// Delegates to static `RFC_4648.Base64.decode(_:into:strictness:)`.
    @inlinable
    @discardableResult
    public func decode<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer,
        strictness: RFC_4648.Strictness = .lenient
    ) -> Bool where Buffer.Element == Byte {
        let codes: [ASCII.Code]
        do throws(ASCII.Code.Error) {
            codes = try [ASCII.Code](wrapped.utf8)
        } catch {
            return false
        }
        return RFC_4648.Base64.decode(codes, into: &buffer, strictness: strictness)
    }

    /// Decodes wrapped Base64 string to bytes
    ///
    /// Delegates to static `RFC_4648.Base64.decode(_:strictness:)`.
    @inlinable
    public func decoded(strictness: RFC_4648.Strictness = .lenient) -> [Byte]? {
        RFC_4648.Base64.decode(wrapped, strictness: strictness)
    }

    /// Decodes wrapped Base64 string to a FixedWidthInteger
    ///
    /// Lifts `wrapped.utf8` to the `ASCII.Code` substrate at entry.
    /// Returns `nil` if the string contains non-ASCII bytes.
    /// Delegates to static `RFC_4648.Base64.decode(_:as:)`.
    @inlinable
    public func decoded<T: FixedWidthInteger>(as type: T.Type = T.self) -> T? {
        let codes: [ASCII.Code]
        do throws(ASCII.Code.Error) {
            codes = try [ASCII.Code](wrapped.utf8)
        } catch {
            return nil
        }
        return RFC_4648.Base64.decode(codes, as: type)
    }
}
