import ASCII

extension Array where Element == Byte {

    @inlinable
    public init?(
        base64Encoded string: some StringProtocol,
        strictness: IETF.RFC.`4648`.Strictness = .lenient
    ) {
        guard let decoded = IETF.RFC.`4648`.Base64.decode(string, strictness: strictness) else {
            return nil
        }
        self = decoded
    }

    @inlinable
    public init?(
        base64URLEncoded string: some StringProtocol,
        strictness: IETF.RFC.`4648`.Strictness = .lenient
    ) {
        guard let decoded = IETF.RFC.`4648`.Base64.URL.decode(string, strictness: strictness) else {
            return nil
        }
        self = decoded
    }

    @inlinable
    public init?(
        base32Encoded string: some StringProtocol,
        strictness: IETF.RFC.`4648`.Strictness = .lenient
    ) {
        guard let decoded = IETF.RFC.`4648`.Base32.decode(string, strictness: strictness) else {
            return nil
        }
        self = decoded
    }

    @inlinable
    public init?(
        base32HexEncoded string: some StringProtocol,
        strictness: IETF.RFC.`4648`.Strictness = .lenient
    ) {
        guard let decoded = IETF.RFC.`4648`.Base32.Hex.decode(string, strictness: strictness) else {
            return nil
        }
        self = decoded
    }

    @inlinable
    public init?(hexEncoded string: some StringProtocol) {
        guard let decoded = IETF.RFC.`4648`.Base16.decode(string, skipPrefix: true) else { return nil }
        self = decoded
    }
}

extension Swift::Collection where Element == Byte {

    @inlinable
    public var base64: IETF.RFC.`4648`.Base64.Wrapper<Self> {
        IETF.RFC.`4648`.Base64.Wrapper(self)
    }

    @inlinable
    public var base32: IETF.RFC.`4648`.Base32.Wrapper<Self> {
        IETF.RFC.`4648`.Base32.Wrapper(self)
    }

    @inlinable
    public var hex: IETF.RFC.`4648`.Base16.Wrapper<Self> {
        IETF.RFC.`4648`.Base16.Wrapper(self)
    }
}

extension Swift::Collection where Element == ASCII.Code {

    @inlinable
    public var base64: IETF.RFC.`4648`.Base64.Wrapper<Self> {
        IETF.RFC.`4648`.Base64.Wrapper(self)
    }

    @inlinable
    public var base32: IETF.RFC.`4648`.Base32.Wrapper<Self> {
        IETF.RFC.`4648`.Base32.Wrapper(self)
    }

    @inlinable
    public var hex: IETF.RFC.`4648`.Base16.Wrapper<Self> {
        IETF.RFC.`4648`.Base16.Wrapper(self)
    }
}
