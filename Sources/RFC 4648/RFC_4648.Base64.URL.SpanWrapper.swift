//
//  RFC_4648.Base64.URL.SpanWrapper.swift
//  swift-rfc-4648
//
//  Span-based URL-safe Base64 encoding wrapper for zero-copy encoding.

// MARK: - Base64.URL Span Support

import ASCII_Primitives

extension RFC_4648.Base64.URL {
    /// Wrapper for Span-based URL-safe Base64 encoding
    public struct SpanWrapper: ~Copyable, ~Escapable {
        @usableFromInline
        let span: Span<Byte>

        @inlinable
        @_lifetime(copy span)
        init(_ span: Span<Byte>) {
            self.span = span
        }
    }
}

extension RFC_4648.Base64.URL.SpanWrapper {
    /// Encodes span bytes to URL-safe Base64 string
    ///
    /// - Parameter padding: Whether to include padding characters (default: false)
    /// - Returns: URL-safe Base64 encoded string
    @inlinable
    public func encoded(padding: Bool = false) -> String {
        unsafe span.withUnsafeBufferPointer { buffer in
            unsafe String(decoding: RFC_4648.Base64.URL.encode(buffer, padding: padding) as [ASCII.Code], as: UTF8.self)
        }
    }
}
