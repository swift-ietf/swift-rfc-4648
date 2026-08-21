public import Binary_Primitives
import Standard_Library_Extensions

extension FixedWidthInteger {

    @inlinable
    public init?(base64Encoded string: some StringProtocol) {
        guard let bytes = RFC_4648.Base64.decode(string) else { return nil }
        self.init(bytes: bytes, endianness: .big)
    }

    @inlinable
    public init?(base64URLEncoded string: some StringProtocol) {
        guard let bytes = RFC_4648.Base64.URL.decode(string) else { return nil }
        self.init(bytes: bytes, endianness: .big)
    }

    @inlinable
    public init?(base32Encoded string: some StringProtocol) {
        guard let bytes = RFC_4648.Base32.decode(string) else { return nil }
        self.init(bytes: bytes, endianness: .big)
    }

    @inlinable
    public init?(base32HexEncoded string: some StringProtocol) {
        guard let bytes = RFC_4648.Base32.Hex.decode(string) else { return nil }
        self.init(bytes: bytes, endianness: .big)
    }

    @inlinable
    public init?(hexEncoded string: some StringProtocol) {
        guard let bytes = RFC_4648.Base16.decode(string, skipPrefix: true) else { return nil }
        self.init(bytes: bytes, endianness: .big)
    }
}
