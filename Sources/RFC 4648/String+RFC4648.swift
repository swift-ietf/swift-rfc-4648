extension String {

    public static let base64 = RFC_4648.Base64.Encoder()

    public static let base64URL = RFC_4648.Base64.URL.Encoder()

    public static let base32 = RFC_4648.Base32.Encoder()

    public static let base32Hex = RFC_4648.Base32.Hex.Encoder()

    public static let hex = RFC_4648.Base16.Encoder()

    public static let base16 = RFC_4648.Base16.Encoder()
}

extension StringProtocol {

    @inlinable
    public var base64: RFC_4648.Base64.Wrapper<Self> {
        RFC_4648.Base64.Wrapper(self)
    }

    @inlinable
    public var base64URL: RFC_4648.Base64.URL.Wrapper<Self> {
        RFC_4648.Base64.URL.Wrapper(self)
    }

    @inlinable
    public var base32: RFC_4648.Base32.Wrapper<Self> {
        RFC_4648.Base32.Wrapper(self)
    }

    @inlinable
    public var base32Hex: RFC_4648.Base32.Hex.Wrapper<Self> {
        RFC_4648.Base32.Hex.Wrapper(self)
    }

    @inlinable
    public var hex: RFC_4648.Base16.Wrapper<Self> {
        RFC_4648.Base16.Wrapper(self)
    }

    @inlinable
    public var base16: RFC_4648.Base16.Wrapper<Self> {
        RFC_4648.Base16.Wrapper(self)
    }
}
