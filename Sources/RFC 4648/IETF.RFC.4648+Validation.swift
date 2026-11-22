extension IETF.RFC.`4648`.Base64 {

    @inlinable
    public static func isValid(_ string: some StringProtocol) -> Bool {
        decode(string) != nil
    }
}

extension IETF.RFC.`4648`.Base64.URL {

    @inlinable
    public static func isValid(_ string: some StringProtocol) -> Bool {
        decode(string) != nil
    }
}

extension IETF.RFC.`4648`.Base32 {

    @inlinable
    public static func isValid(_ string: some StringProtocol) -> Bool {
        decode(string) != nil
    }
}

extension IETF.RFC.`4648`.Base32.Hex {

    @inlinable
    public static func isValid(_ string: some StringProtocol) -> Bool {
        decode(string) != nil
    }
}

extension IETF.RFC.`4648`.Base16 {

    @inlinable
    public static func isValid(_ string: some StringProtocol) -> Bool {
        decode(string, skipPrefix: true) != nil
    }
}

extension IETF.RFC.`4648`.Base64.Wrapper where Wrapped: StringProtocol {

    @inlinable
    public var isValid: Bool {
        IETF.RFC.`4648`.Base64.isValid(wrapped)
    }
}

extension IETF.RFC.`4648`.Base64.URL.Wrapper where Wrapped: StringProtocol {

    @inlinable
    public var isValid: Bool {
        IETF.RFC.`4648`.Base64.URL.isValid(wrapped)
    }
}

extension IETF.RFC.`4648`.Base32.Wrapper where Wrapped: StringProtocol {

    @inlinable
    public var isValid: Bool {
        IETF.RFC.`4648`.Base32.isValid(wrapped)
    }
}

extension IETF.RFC.`4648`.Base32.Hex.Wrapper where Wrapped: StringProtocol {

    @inlinable
    public var isValid: Bool {
        IETF.RFC.`4648`.Base32.Hex.isValid(wrapped)
    }
}

extension IETF.RFC.`4648`.Base16.Wrapper where Wrapped: StringProtocol {

    @inlinable
    public var isValid: Bool {
        IETF.RFC.`4648`.Base16.isValid(wrapped)
    }
}
