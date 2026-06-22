//
//  Span+RFC_4648.swift
//  swift-rfc-4648
//
//  Span extensions for zero-copy encoding from borrowed memory.
//
//  Enables encoding directly from stack-allocated buffers or borrowed memory
//  without intermediate Array allocation.
//
//  ## Usage
//
//  ```swift
//  withUnsafeTemporaryAllocation(of: UInt8.self, capacity: 12) { buffer in
//      arc4random_buf(buffer.baseAddress!, 12)
//      let span = Span(_unsafeElements: buffer)
//      return span.hex.encoded()  // No intermediate Array allocation
//  }
//  ```

// MARK: - Span Extensions

import ASCII_Primitives

extension Span where Element == Byte {
    /// Access to Base16/Hex encoding for Span
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let span: Swift.Span<Byte> = ...
    /// span.hex.encoded()  // "deadbeef"
    /// span.hex.encoded(uppercase: true)  // "DEADBEEF"
    /// ```
    @inlinable
    public var hex: RFC_4648.Base16.SpanWrapper {
        @_lifetime(copy self)
        get {
            RFC_4648.Base16.SpanWrapper(self)
        }
    }

    /// Access to Base64 encoding for Span
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let span: Swift.Span<Byte> = ...
    /// span.base64.encoded()  // Standard Base64
    /// span.base64.url.encoded()  // URL-safe Base64
    /// ```
    @inlinable
    public var base64: RFC_4648.Base64.SpanWrapper {
        @_lifetime(copy self)
        get {
            RFC_4648.Base64.SpanWrapper(self)
        }
    }

    /// Access to Base32 encoding for Span
    ///
    /// ## Usage
    ///
    /// ```swift
    /// let span: Swift.Span<Byte> = ...
    /// span.base32.encoded()  // Standard Base32
    /// span.base32.hex.encoded()  // Base32-HEX
    /// ```
    @inlinable
    public var base32: RFC_4648.Base32.SpanWrapper {
        @_lifetime(copy self)
        get {
            RFC_4648.Base32.SpanWrapper(self)
        }
    }
}
