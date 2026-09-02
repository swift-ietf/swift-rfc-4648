public import Foundation
import RFC_4648

extension Data {

    public func base64URLEncodedString(padding: Bool = false) -> String {
        String.base64.url(self.map(Byte.init(bitPattern:)), padding: padding)
    }

    public init?(base64URLEncoded string: String) {
        guard let bytes = [Byte](base64URLEncoded: string) else { return nil }
        self.init(bytes.map(\.bitPattern))
    }
}

extension Data {

    public func base32EncodedString(padding: Bool = true) -> String {
        String.base32(self.map(Byte.init(bitPattern:)), padding: padding)
    }

    public init?(base32Encoded string: String) {
        guard let bytes = [Byte](base32Encoded: string) else { return nil }
        self.init(bytes.map(\.bitPattern))
    }
}

extension Data {

    public func base32HexEncodedString(padding: Bool = true) -> String {
        String.base32.hex(self.map(Byte.init(bitPattern:)), padding: padding)
    }

    public init?(base32HexEncoded string: String) {
        guard let bytes = [Byte](base32HexEncoded: string) else { return nil }
        self.init(bytes.map(\.bitPattern))
    }
}

extension Data {

    public func hexEncodedString(uppercase: Bool = false) -> String {
        String.hex(self.map(Byte.init(bitPattern:)), uppercase: uppercase)
    }

    public init?(hexEncoded string: String) {
        guard let bytes = [Byte](hexEncoded: string) else { return nil }
        self.init(bytes.map(\.bitPattern))
    }
}
