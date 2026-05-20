//
//  RFC_4648.Base64.SpanWrapper.swift
//  swift-rfc-4648
//
//  Span-based Base64 encoding wrapper for zero-copy encoding.

// MARK: - Base64 Span Support

import ASCII_Primitives

extension RFC_4648.Base64 {
    /// Wrapper for Span-based Base64 encoding
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

extension RFC_4648.Base64.SpanWrapper {
    /// Encodes span bytes to Base64 string
    ///
    /// - Parameter padding: Whether to include padding characters (default: true)
    /// - Returns: Base64 encoded string
    @inlinable
    public func encoded(padding: Bool = true) -> String {
        unsafe span.withUnsafeBufferPointer { buffer in
            unsafe String(decoding: RFC_4648.Base64.encode(buffer, padding: padding) as [ASCII.Code], as: UTF8.self)
        }
    }

    /// Access to URL-safe Base64 encoding
    @inlinable
    public var url: RFC_4648.Base64.URL.SpanWrapper {
        @_lifetime(copy self)
        get {
            RFC_4648.Base64.URL.SpanWrapper(span)
        }
    }
}
