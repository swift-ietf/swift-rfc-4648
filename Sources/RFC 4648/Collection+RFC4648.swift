import ASCII_Primitives

extension Array where Element == Byte {

    @inlinable
    public init?(
        base64Encoded string: some StringProtocol,
        strictness: RFC_4648.Strictness = .lenient
    ) {
        guard let decoded = RFC_4648.Base64.decode(string, strictness: strictness) else {
            return nil
        }
        self = decoded
    }

    @inlinable
    public init?(
        base64URLEncoded string: some StringProtocol,
        strictness: RFC_4648.Strictness = .lenient
    ) {
        guard let decoded = RFC_4648.Base64.URL.decode(string, strictness: strictness) else {
            return nil
        }
        self = decoded
    }

    @inlinable
    public init?(
        base32Encoded string: some StringProtocol,
        strictness: RFC_4648.Strictness = .lenient
    ) {
        guard let decoded = RFC_4648.Base32.decode(string, strictness: strictness) else {
            return nil
        }
        self = decoded
    }

    @inlinable
    public init?(
        base32HexEncoded string: some StringProtocol,
        strictness: RFC_4648.Strictness = .lenient
    ) {
        guard let decoded = RFC_4648.Base32.Hex.decode(string, strictness: strictness) else {
            return nil
        }
        self = decoded
    }

    @inlinable
    public init?(hexEncoded string: some StringProtocol) {
        guard let decoded = RFC_4648.Base16.decode(string, skipPrefix: true) else { return nil }
        self = decoded
    }
}

extension Collection where Element == Byte {

    @inlinable
    public var base64: RFC_4648.Base64.Wrapper<Self> {
        RFC_4648.Base64.Wrapper(self)
    }

    @inlinable
    public var base32: RFC_4648.Base32.Wrapper<Self> {
        RFC_4648.Base32.Wrapper(self)
    }

    @inlinable
    public var hex: RFC_4648.Base16.Wrapper<Self> {
        RFC_4648.Base16.Wrapper(self)
    }
}

extension Collection where Element == ASCII.Code {

    @inlinable
    public var base64: RFC_4648.Base64.Wrapper<Self> {
        RFC_4648.Base64.Wrapper(self)
    }

    @inlinable
    public var base32: RFC_4648.Base32.Wrapper<Self> {
        RFC_4648.Base32.Wrapper(self)
    }

    @inlinable
    public var hex: RFC_4648.Base16.Wrapper<Self> {
        RFC_4648.Base16.Wrapper(self)
    }
}
