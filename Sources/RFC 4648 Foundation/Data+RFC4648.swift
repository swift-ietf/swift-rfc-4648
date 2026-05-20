// Data+RFC4648.swift
// swift-rfc-4648
//
// Foundation Data extensions for RFC 4648 encodings
// Note: Foundation already provides Base64 encoding, so we only add the encodings it doesn't have.
//
// Bridges across the byte-domain boundary: Data is Sequence<UInt8> in stdlib;
// rfc-4648's public surface is Byte-typed per codec-split-design (2026-05-20).
// Lifting to Byte at encode entry uses Array<Byte>(self) from
// Byte_Primitives_Standard_Library_Integration; lowering at decode exit uses
// `[Byte].underlying: [UInt8]`.

public import Foundation
import RFC_4648

// MARK: - Base64URL (RFC 4648 Section 5)

extension Data {
    /// Creates a Base64URL encoded string from data (RFC 4648 Section 5)
    public func base64URLEncodedString(padding: Bool = false) -> String {
        String.base64.url(Array<Byte>(self), padding: padding)
    }

    /// Creates data from a Base64URL encoded string (RFC 4648 Section 5)
    public init?(base64URLEncoded string: String) {
        guard let bytes = [Byte](base64URLEncoded: string) else { return nil }
        self.init(bytes.underlying)
    }
}

// MARK: - Base32 (RFC 4648 Section 6)

extension Data {
    /// Creates a Base32 encoded string from data (RFC 4648 Section 6)
    public func base32EncodedString(padding: Bool = true) -> String {
        String.base32(Array<Byte>(self), padding: padding)
    }

    /// Creates data from a Base32 encoded string (RFC 4648 Section 6)
    public init?(base32Encoded string: String) {
        guard let bytes = [Byte](base32Encoded: string) else { return nil }
        self.init(bytes.underlying)
    }
}

// MARK: - Base32-HEX (RFC 4648 Section 7)

extension Data {
    /// Creates a Base32-HEX encoded string from data (RFC 4648 Section 7)
    public func base32HexEncodedString(padding: Bool = true) -> String {
        String.base32.hex(Array<Byte>(self), padding: padding)
    }

    /// Creates data from a Base32-HEX encoded string (RFC 4648 Section 7)
    public init?(base32HexEncoded string: String) {
        guard let bytes = [Byte](base32HexEncoded: string) else { return nil }
        self.init(bytes.underlying)
    }
}

// MARK: - Base16/Hex (RFC 4648 Section 8)

extension Data {
    /// Creates a Base16 (hexadecimal) encoded string from data (RFC 4648 Section 8)
    public func hexEncodedString(uppercase: Bool = false) -> String {
        String.hex(Array<Byte>(self), uppercase: uppercase)
    }

    /// Creates data from a Base16 (hexadecimal) encoded string (RFC 4648 Section 8)
    public init?(hexEncoded string: String) {
        guard let bytes = [Byte](hexEncoded: string) else { return nil }
        self.init(bytes.underlying)
    }
}
