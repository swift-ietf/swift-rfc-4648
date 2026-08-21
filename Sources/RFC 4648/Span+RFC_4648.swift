import ASCII_Primitives

extension Span where Element == Byte {

    @inlinable
    public var hex: RFC_4648.Base16.SpanWrapper {
        @_lifetime(copy self)
        get {
            RFC_4648.Base16.SpanWrapper(self)
        }
    }

    @inlinable
    public var base64: RFC_4648.Base64.SpanWrapper {
        @_lifetime(copy self)
        get {
            RFC_4648.Base64.SpanWrapper(self)
        }
    }

    @inlinable
    public var base32: RFC_4648.Base32.SpanWrapper {
        @_lifetime(copy self)
        get {
            RFC_4648.Base32.SpanWrapper(self)
        }
    }
}
