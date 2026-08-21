import ASCII_Primitives

extension RFC_4648.Base32.Hex {

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

extension RFC_4648.Base32.Hex.SpanWrapper {

    @inlinable
    public func encoded(padding: Bool = true) -> String {
        span.withUnsafeBufferPointer { buffer in
            unsafe String(
                decoding: RFC_4648.Base32.Hex.encode(buffer, padding: padding) as [ASCII.Code],
                as: UTF8.self
            )
        }
    }
}
