import ASCII

extension Span where Element == Byte {

    @inlinable
    public var hex: IETF.RFC.`4648`.Base16.SpanWrapper {
        @_lifetime(copy self)
        get {
            IETF.RFC.`4648`.Base16.SpanWrapper(self)
        }
    }

    @inlinable
    public var base64: IETF.RFC.`4648`.Base64.SpanWrapper {
        @_lifetime(copy self)
        get {
            IETF.RFC.`4648`.Base64.SpanWrapper(self)
        }
    }

    @inlinable
    public var base32: IETF.RFC.`4648`.Base32.SpanWrapper {
        @_lifetime(copy self)
        get {
            IETF.RFC.`4648`.Base32.SpanWrapper(self)
        }
    }
}
