extension RFC_4648.Base64 {

    @inlinable
    public static func isValid(_ string: some StringProtocol) -> Bool {
        decode(string) != nil
    }
}

extension RFC_4648.Base64.URL {

    @inlinable
    public static func isValid(_ string: some StringProtocol) -> Bool {
        decode(string) != nil
    }
}

extension RFC_4648.Base32 {

    @inlinable
    public static func isValid(_ string: some StringProtocol) -> Bool {
        decode(string) != nil
    }
}

extension RFC_4648.Base32.Hex {

    @inlinable
    public static func isValid(_ string: some StringProtocol) -> Bool {
        decode(string) != nil
    }
}

extension RFC_4648.Base16 {

    @inlinable
    public static func isValid(_ string: some StringProtocol) -> Bool {
        decode(string, skipPrefix: true) != nil
    }
}

extension RFC_4648.Base64.Wrapper where Wrapped: StringProtocol {

    @inlinable
    public var isValid: Bool {
        RFC_4648.Base64.isValid(wrapped)
    }
}

extension RFC_4648.Base64.URL.Wrapper where Wrapped: StringProtocol {

    @inlinable
    public var isValid: Bool {
        RFC_4648.Base64.URL.isValid(wrapped)
    }
}

extension RFC_4648.Base32.Wrapper where Wrapped: StringProtocol {

    @inlinable
    public var isValid: Bool {
        RFC_4648.Base32.isValid(wrapped)
    }
}

extension RFC_4648.Base32.Hex.Wrapper where Wrapped: StringProtocol {

    @inlinable
    public var isValid: Bool {
        RFC_4648.Base32.Hex.isValid(wrapped)
    }
}

extension RFC_4648.Base16.Wrapper where Wrapped: StringProtocol {

    @inlinable
    public var isValid: Bool {
        RFC_4648.Base16.isValid(wrapped)
    }
}
