//
//  RFC_4648.Base64.Encoder.swift
//  swift-rfc-4648
//
//  Base64 Encoder for String.base64(bytes) syntax

import ASCII_Primitives
public import Binary_Primitives

// MARK: - Encoder (for String.base64(...) syntax)

extension RFC_4648.Base64 {
    /// Encoder for `String.base64(bytes)` syntax
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let encoded = String.base64([72, 101, 108, 108, 111])  // "SGVsbG8="
    /// let encoded = String.base64.url([72, 101, 108, 108, 111])  // "SGVsbG8"
    /// ```
    public struct Encoder: Sendable {
        @inlinable
        public init() {}

        /// Encodes bytes to Base64 string
        @inlinable
        public func callAsFunction<Bytes: Collection>(
            _ bytes: Bytes,
            padding: Bool = true
        ) -> String where Bytes.Element == Byte {
            String(decoding: RFC_4648.Base64.encode(bytes, padding: padding), as: UTF8.self)
        }

        /// Encodes an integer to Base64 string (big-endian byte order)
        @inlinable
        public func callAsFunction<T: FixedWidthInteger>(
            _ value: T,
            padding: Bool = true
        ) -> String {
            callAsFunction(value.bytes(endianness: .big), padding: padding)
        }

        /// Access to Base64URL encoder
        @inlinable
        public var url: RFC_4648.Base64.URL.Encoder {
            RFC_4648.Base64.URL.Encoder()
        }
    }
}
