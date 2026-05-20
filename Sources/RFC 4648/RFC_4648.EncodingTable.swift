// RFC_4648.EncodingTable.swift
// swift-rfc-4648
//
// Primitive encoding table structure for RFC 4648 encodings.
//
// Per the codec-split-design (2026-05-20), `encode` is `[ASCII.Code]` (encoded
// form = ASCII alphabet per spec) and `decode` is `[UInt8?]` — sextet/quintet/
// nibble values 0-63/0-31/0-15 are arithmetic-domain UInt8 per Q3
// ([API-BYTE-004]); Optional wrapping types the validity signal at the type
// system level (nil = invalid) per HANDOFF Recommended Default.

public import ASCII_Primitives

extension RFC_4648 {
    /// Encoding table pairing encode and decode lookups
    public struct EncodingTable: Sendable {
        /// Encoding lookup table: maps value (0-63 for Base64, 0-31 for Base32, 0-15 for Hex) to ASCII character
        public let encode: [ASCII.Code]

        /// Decoding lookup table: maps raw byte value (0-255) to sextet/quintet/nibble value, `nil` for invalid characters
        public let decode: [UInt8?]

        /// Creates an encoding table with explicit encode and decode tables
        public init(encode: [ASCII.Code], decode: [UInt8?]) {
            self.encode = encode
            self.decode = decode
        }

        /// Creates an encoding table, automatically generating decode table from encode table
        /// - Parameter caseInsensitive: If true, maps both uppercase and lowercase letters to same value
        public init(encode: [ASCII.Code], caseInsensitive: Bool = false) {
            self.encode = encode
            var decodeTable = [UInt8?](repeating: nil, count: 256)
            for (index, char) in encode.enumerated() {
                let raw = char.underlying
                decodeTable[Int(raw)] = UInt8(index)

                // For case-insensitive encodings, map both cases
                if caseInsensitive {
                    if raw >= 0x41, raw <= 0x5A {  // A-Z
                        decodeTable[Int(raw + 32)] = UInt8(index)  // a-z
                    } else if raw >= 0x61, raw <= 0x7A {  // a-z
                        decodeTable[Int(raw - 32)] = UInt8(index)  // A-Z
                    }
                }
            }
            decode = decodeTable
        }
    }
}
