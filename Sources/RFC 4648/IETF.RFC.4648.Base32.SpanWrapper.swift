import ASCII

extension IETF.RFC.`4648`.Base32 {

    public struct SpanWrapper: ~Copyable, ~Escapable {
        @usableFromInline
        let span: Swift::Span<Byte>

        @inlinable
        @_lifetime(copy span)
        package init(_ span: Swift::Span<Byte>) {
            self.span = span
        }
    }
}

extension IETF.RFC.`4648`.Base32.SpanWrapper {

    @inlinable
    public func encoded(padding: Bool = true) -> String {
        span.withUnsafeBufferPointer { buffer in
            unsafe String(
                decoding: (IETF.RFC.`4648`.Base32.encode(buffer, padding: padding) as [ASCII.Code])
                    .map({ $0.underlying }),
                as: UTF8.self
            )
        }
    }

    @inlinable
    public var hex: IETF.RFC.`4648`.Base32.Hex.SpanWrapper {
        @_lifetime(copy self)
        get {
            IETF.RFC.`4648`.Base32.Hex.SpanWrapper(span)
        }
    }
}
