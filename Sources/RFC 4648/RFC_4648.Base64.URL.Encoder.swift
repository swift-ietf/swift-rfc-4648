//
//  RFC_4648.Base64.URL.Encoder.swift
//  swift-rfc-4648
//
//  Base64URL Encoder for String.base64.url(bytes) syntax

import ASCII_Primitives
public import Binary_Primitives

// MARK: - Encoder (for String.base64.url(...) syntax)

extension RFC_4648.Base64.URL {
    /// Encoder for `String.base64.url(bytes)` syntax
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let encoded = String.base64.url([72, 101, 108, 108, 111])  // "SGVsbG8"
    /// ```
    public struct Encoder: Sendable {
        @inlinable
        public init() {}

        /// Encodes bytes to Base64URL string
        @inlinable
        public func callAsFunction<Bytes: Collection>(
            _ bytes: Bytes,
            padding: Bool = false
        ) -> String where Bytes.Element == Byte {
            String(decoding: RFC_4648.Base64.URL.encode(bytes, padding: padding), as: UTF8.self)
        }

        /// Encodes an integer to Base64URL string (big-endian byte order)
        @inlinable
        public func callAsFunction<T: FixedWidthInteger>(
            _ value: T,
            padding: Bool = false
        ) -> String {
            callAsFunction(value.bytes(endianness: .big), padding: padding)
        }
    }
}
