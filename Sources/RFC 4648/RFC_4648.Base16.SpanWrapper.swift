import ASCII

extension RFC_4648.Base16 {

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

extension RFC_4648.Base16.SpanWrapper {

    @inlinable
    public func encoded(uppercase: Bool = false) -> String {
        span.withUnsafeBufferPointer { buffer in
            unsafe String(
                decoding: RFC_4648.Base16.encode(buffer, uppercase: uppercase) as [ASCII.Code],
                as: UTF8.self
            )
        }
    }

    @inlinable
    public func callAsFunction(uppercase: Bool = false) -> String {
        encoded(uppercase: uppercase)
    }
}
