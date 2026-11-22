extension String {

    public static let base64 = IETF.RFC.`4648`.Base64.Encoder()

    public static let base64URL = IETF.RFC.`4648`.Base64.URL.Encoder()

    public static let base32 = IETF.RFC.`4648`.Base32.Encoder()

    public static let base32Hex = IETF.RFC.`4648`.Base32.Hex.Encoder()

    public static let hex = IETF.RFC.`4648`.Base16.Encoder()

    public static let base16 = IETF.RFC.`4648`.Base16.Encoder()
}

extension StringProtocol {

    @inlinable
    public var base64: IETF.RFC.`4648`.Base64.Wrapper<Self> {
        IETF.RFC.`4648`.Base64.Wrapper(self)
    }

    @inlinable
    public var base64URL: IETF.RFC.`4648`.Base64.URL.Wrapper<Self> {
        IETF.RFC.`4648`.Base64.URL.Wrapper(self)
    }

    @inlinable
    public var base32: IETF.RFC.`4648`.Base32.Wrapper<Self> {
        IETF.RFC.`4648`.Base32.Wrapper(self)
    }

    @inlinable
    public var base32Hex: IETF.RFC.`4648`.Base32.Hex.Wrapper<Self> {
        IETF.RFC.`4648`.Base32.Hex.Wrapper(self)
    }

    @inlinable
    public var hex: IETF.RFC.`4648`.Base16.Wrapper<Self> {
        IETF.RFC.`4648`.Base16.Wrapper(self)
    }

    @inlinable
    public var base16: IETF.RFC.`4648`.Base16.Wrapper<Self> {
        IETF.RFC.`4648`.Base16.Wrapper(self)
    }
}
