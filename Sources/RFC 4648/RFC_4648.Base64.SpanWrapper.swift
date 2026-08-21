import ASCII_Primitives

extension RFC_4648.Base64 {

    public struct SpanWrapper: ~Copyable, ~Escapable {
        @usableFromInline
        let span: Swift.Span<Byte>

        @inlinable
        @_lifetime(copy span)
        package init(_ span: Swift.Span<Byte>) {
            self.span = span
        }
    }
}

extension RFC_4648.Base64.SpanWrapper {

    @inlinable
    public func encoded(padding: Bool = true) -> String {
        span.withUnsafeBufferPointer { buffer in
            unsafe String(
                decoding: RFC_4648.Base64.encode(buffer, padding: padding) as [ASCII.Code],
                as: UTF8.self
            )
        }
    }

    @inlinable
    public var url: RFC_4648.Base64.URL.SpanWrapper {
        @_lifetime(copy self)
        get {
            RFC_4648.Base64.URL.SpanWrapper(span)
        }
    }
}
