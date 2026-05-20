//
//  RFC_4648.Base32.Encoder.swift
//  swift-rfc-4648
//
//  Base32 Encoder for String.base32(bytes) syntax

import ASCII_Primitives
public import Binary_Primitives

// MARK: - Encoder (for String.base32(...) syntax)

extension RFC_4648.Base32 {
    /// Encoder for `String.base32(bytes)` syntax
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let encoded = String.base32([72, 101, 108, 108, 111])  // "JBSWY3DP"
    /// let encoded = String.base32.hex([72, 101, 108, 108, 111])  // "91IMOR3F"
    /// ```
    public struct Encoder: Sendable {
        @inlinable
        public init() {}

        /// Encodes bytes to Base32 string
        @inlinable
        public func callAsFunction<Bytes: Collection>(
            _ bytes: Bytes,
            padding: Bool = true
        ) -> String where Bytes.Element == Byte {
            String(decoding: RFC_4648.Base32.encode(bytes, padding: padding), as: UTF8.self)
        }

        /// Encodes an integer to Base32 string (big-endian byte order)
        @inlinable
        public func callAsFunction<T: FixedWidthInteger>(
            _ value: T,
            padding: Bool = true
        ) -> String {
            callAsFunction(value.bytes(endianness: .big), padding: padding)
        }

        /// Access to Base32-HEX encoder
        @inlinable
        public var hex: RFC_4648.Base32.Hex.Encoder {
            RFC_4648.Base32.Hex.Encoder()
        }
    }
}
