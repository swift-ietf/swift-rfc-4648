//
//  RFC_4648.Base16.Encoder.swift
//  swift-rfc-4648
//
//  Base16 Encoder for String.hex(bytes) syntax

import ASCII_Primitives
public import Binary_Primitives

// MARK: - Encoder (for String.hex(...) syntax)

extension RFC_4648.Base16 {
    /// Encoder for `String.hex(bytes)` syntax
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let encoded = String.hex([0xde, 0xad, 0xbe, 0xef])  // "deadbeef"
    /// let encoded = String.hex([0xde, 0xad], uppercase: true)  // "DEAD"
    /// ```
    public struct Encoder: Sendable {
        @inlinable
        public init() {}

        /// Encodes bytes to hexadecimal string
        @inlinable
        public func callAsFunction<Bytes: Collection>(
            _ bytes: Bytes,
            uppercase: Bool = false
        ) -> String where Bytes.Element == Byte {
            let encoded: [ASCII.Code] = RFC_4648.Base16.encode(bytes, uppercase: uppercase)
            return String(decoding: encoded, as: UTF8.self)
        }

        /// Encodes an integer to hexadecimal string (big-endian byte order)
        ///
        /// - Parameters:
        ///   - value: The integer to encode
        ///   - prefix: Optional prefix (default: "0x")
        ///   - uppercase: Whether to use uppercase hex digits (default: false)
        /// - Returns: Prefixed hexadecimal string
        @inlinable
        public func callAsFunction<T: FixedWidthInteger>(
            _ value: T,
            prefix: String = "0x",
            uppercase: Bool = false
        ) -> String {
            prefix + callAsFunction(value.bytes(endianness: .big), uppercase: uppercase)
        }
    }
}
