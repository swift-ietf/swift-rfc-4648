public import Foundation
import RFC_4648

extension Data {

    public func base64URLEncodedString(padding: Bool = false) -> String {
        String.base64.url([Byte](self), padding: padding)
    }

    public init?(base64URLEncoded string: String) {
        guard let bytes = [Byte](base64URLEncoded: string) else { return nil }
        self.init(bytes.underlying)
    }
}

extension Data {

    public func base32EncodedString(padding: Bool = true) -> String {
        String.base32([Byte](self), padding: padding)
    }

    public init?(base32Encoded string: String) {
        guard let bytes = [Byte](base32Encoded: string) else { return nil }
        self.init(bytes.underlying)
    }
}

extension Data {

    public func base32HexEncodedString(padding: Bool = true) -> String {
        String.base32.hex([Byte](self), padding: padding)
    }

    public init?(base32HexEncoded string: String) {
        guard let bytes = [Byte](base32HexEncoded: string) else { return nil }
        self.init(bytes.underlying)
    }
}

extension Data {

    public func hexEncodedString(uppercase: Bool = false) -> String {
        String.hex([Byte](self), uppercase: uppercase)
    }

    public init?(hexEncoded string: String) {
        guard let bytes = [Byte](hexEncoded: string) else { return nil }
        self.init(bytes.underlying)
    }
}
