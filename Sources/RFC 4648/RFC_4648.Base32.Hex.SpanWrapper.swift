//
//  RFC_4648.Base32.Hex.SpanWrapper.swift
//  swift-rfc-4648
//
//  Span-based Base32-HEX encoding wrapper for zero-copy encoding.

// MARK: - Base32.Hex Span Support

import ASCII_Primitives

extension RFC_4648.Base32.Hex {
    /// Wrapper for Span-based Base32-HEX encoding
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

extension RFC_4648.Base32.Hex.SpanWrapper {
    /// Encodes span bytes to Base32-HEX string
    ///
    /// - Parameter padding: Whether to include padding characters (default: true)
    /// - Returns: Base32-HEX encoded string
    @inlinable
    public func encoded(padding: Bool = true) -> String {
        unsafe span.withUnsafeBufferPointer { buffer in
            unsafe String(decoding: RFC_4648.Base32.Hex.encode(buffer, padding: padding) as [ASCII.Code], as: UTF8.self)
        }
    }
}
