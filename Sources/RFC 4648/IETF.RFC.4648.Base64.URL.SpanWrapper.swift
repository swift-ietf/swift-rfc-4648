import ASCII

extension IETF.RFC.`4648`.Base64.URL {

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

extension IETF.RFC.`4648`.Base64.URL.SpanWrapper {

    @inlinable
    public func encoded(padding: Bool = false) -> String {
        span.withUnsafeBufferPointer { buffer in
            unsafe String(
                decoding: (IETF.RFC.`4648`.Base64.URL.encode(buffer, padding: padding) as [ASCII.Code])
                    .map({ $0.underlying }),
                as: UTF8.self
            )
        }
    }
}
