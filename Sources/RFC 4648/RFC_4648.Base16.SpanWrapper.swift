//
//  RFC_4648.Base16.SpanWrapper.swift
//  swift-rfc-4648
//
//  Span-based hex encoding wrapper for zero-copy Base16 encoding.

// MARK: - Base16 Span Support

import ASCII_Primitives

extension RFC_4648.Base16 {
    /// Wrapper for Span-based hex encoding
    public struct SpanWrapper: ~Copyable, ~Escapable {
        @usableFromInline
        let span: Swift.Span<Byte>

        @inlinable
        @_lifetime(copy span)
        init(_ span: Swift.Span<Byte>) {
            self.span = span
        }
    }
}

extension RFC_4648.Base16.SpanWrapper {
    /// Encodes span bytes to hexadecimal string
    ///
    /// - Parameter uppercase: Whether to use uppercase hex digits (default: false)
    /// - Returns: Hexadecimal encoded string
    @inlinable
    public func encoded(uppercase: Bool = false) -> String {
        unsafe span.withUnsafeBufferPointer { buffer in
            unsafe String(decoding: RFC_4648.Base16.encode(buffer, uppercase: uppercase) as [ASCII.Code], as: UTF8.self)
        }
    }

    /// Callable syntax for encoding
    @inlinable
    public func callAsFunction(uppercase: Bool = false) -> String {
        encoded(uppercase: uppercase)
    }
}
