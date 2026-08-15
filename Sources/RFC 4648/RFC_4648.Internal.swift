// RFC_4648.Internal.swift
// swift-rfc-4648
//
// Internal shared implementations to eliminate code duplication
// These are implementation details, not public API
//
// Per codec-split-design (2026-05-20), per-direction substrate:
// - encode: `Bytes.Element == Byte` IN, `Buffer.Element == ASCII.Code` OUT,
//   `table: [ASCII.Code]`. Body bridges Byte→UInt8 via `.underlying` for
//   arithmetic (Byte has no arithmetic by design per Q3 / [API-BYTE-002]).
// - decode: `Bytes.Element == ASCII.Code` IN, `Buffer.Element == Byte` OUT,
//   `decodeTable: [UInt8?]` (sextet/quintet values are arithmetic-domain
//   UInt8 per Q3; Optional wrapping types validity at the type-system
//   level — nil = invalid). Body bridges UInt8→Byte at buffer boundary.

public import ASCII_Primitives

// MARK: - Base64 Shared Implementation

extension RFC_4648 {
    /// Internal Base64 encoding implementation shared by Base64 and Base64.URL
    ///
    /// - Parameters:
    ///   - bytes: The bytes to encode
    ///   - buffer: The buffer to append encoded characters to
    ///   - table: The encoding table to use (64 characters)
    ///   - padding: Whether to include padding characters
    @inlinable
    package static func encodeBase64<Bytes: Collection, Buffer: RangeReplaceableCollection>(
        _ bytes: Bytes,
        into buffer: inout Buffer,
        table: [ASCII.Code],
        padding: Bool
    ) where Bytes.Element == Byte, Buffer.Element == ASCII.Code {
        guard !bytes.isEmpty else { return }

        var iterator = bytes.makeIterator()

        while let b1Byte = iterator.next() {
            // Bridge Byte → UInt8 at iterator boundary for arithmetic.
            let b1 = b1Byte.underlying
            let b2 = iterator.next()?.underlying
            let b3 = iterator.next()?.underlying

            // First character: high 6 bits of b1
            buffer.append(table[Int((b1 >> 2) & 0x3F)])

            // Second character: low 2 bits of b1 + high 4 bits of b2
            let c2 = ((b1 << 4) | ((b2 ?? 0) >> 4)) & 0x3F
            buffer.append(table[Int(c2)])

            guard let b2 else {
                if padding {
                    buffer.append(RFC_4648.padding)
                    buffer.append(RFC_4648.padding)
                }
                break
            }

            // Third character: low 4 bits of b2 + high 2 bits of b3
            let c3 = ((b2 << 2) | ((b3 ?? 0) >> 6)) & 0x3F
            buffer.append(table[Int(c3)])

            guard let b3 else {
                if padding {
                    buffer.append(RFC_4648.padding)
                }
                break
            }

            // Fourth character: low 6 bits of b3
            buffer.append(table[Int(b3 & 0x3F)])
        }
    }

    /// Internal Base64 decoding implementation shared by Base64 and Base64.URL
    ///
    /// - Parameters:
    ///   - bytes: The encoded bytes to decode
    ///   - buffer: The buffer to append decoded bytes to
    ///   - decodeTable: The decoding table (256 entries, 255 = invalid)
    ///   - requirePadding: Whether to require complete groups of 4
    ///   - strictness: Whitespace/non-canonical-padding posture (default ``RFC_4648/Strictness/lenient``)
    /// - Returns: `true` if decoding succeeded, `false` if invalid input
    @inlinable
    @discardableResult
    package static func decodeBase64<Bytes: Collection, Buffer: RangeReplaceableCollection>(
        _ bytes: Bytes,
        into buffer: inout Buffer,
        decodeTable: [UInt8?],
        requirePadding: Bool,
        strictness: RFC_4648.Strictness = .lenient
    ) -> Bool where Bytes.Element == ASCII.Code, Buffer.Element == Byte {
        guard !bytes.isEmpty else { return true }

        var iterator = bytes.makeIterator()
        var values = [UInt8]()
        values.reserveCapacity(4)
        var hasDecodedAny = false

        // Once a short/padded (terminal) group has been processed, nothing but
        // whitespace may follow it in the iterator. RFC 4648 padding marks the
        // end of the encoded stream — silently discarding whatever comes next
        // (more padding, a second group, arbitrary garbage) accepts input that
        // isn't valid Base64. [F-001]
        func onlyTrailingWhitespaceRemains() -> Bool {
            while let code = iterator.next() {
                if strictness.rejectWhitespace || !code.isWhitespace { return false }
            }
            return true
        }

        while true {
            values.removeAll(keepingCapacity: true)
            var paddingCount = 0

            // Collect up to 4 characters for this group
            while values.count + paddingCount < 4 {
                guard let code = iterator.next() else { break }
                if code == RFC_4648.padding {
                    paddingCount += 1
                    continue
                }
                if code.isWhitespace {
                    if strictness.rejectWhitespace { return false }
                    continue
                }
                // Padding in the middle is invalid
                if paddingCount > 0 { return false }
                guard let value = decodeTable[Int(code.underlying)] else { return false }
                values.append(value)
            }

            let totalChars = values.count + paddingCount

            // Handle end of input
            if totalChars == 0 { break }

            // Validation
            if requirePadding {
                // Standard Base64: must have exactly 4 characters per group
                if totalChars != 4 { return false }
            }

            // A group made entirely of padding is never legal on its own —
            // padding only ever fills out the tail of a data-bearing group.
            // (This is also what rejects a trailing all-padding group after a
            // complete prior group, e.g. "AAAA====".)
            if values.isEmpty { return false }

            // Need at least 2 data characters
            guard values.count >= 2 else { return false }
            hasDecodedAny = true

            // A short final group leaves some low bits of its last sextet
            // unused (they don't map onto a whole output byte). Canonical
            // encoders always emit zero there; a nonzero value means this
            // input isn't the unique canonical encoding of its decoded bytes.
            if strictness.rejectNonzeroTrailingBits {
                switch values.count {
                case 2 where (values[1] & 0x0F) != 0: return false
                case 3 where (values[2] & 0x03) != 0: return false
                default: break
                }
            }

            // First byte: 6 bits from v1 + high 2 bits from v2
            buffer.append(Byte((values[0] << 2) | (values[1] >> 4)))

            if values.count >= 3 {
                // Second byte: low 4 bits from v2 + high 4 bits from v3
                buffer.append(Byte((values[1] << 4) | (values[2] >> 2)))

                if values.count >= 4 {
                    // Third byte: low 2 bits from v3 + 6 bits from v4
                    buffer.append(Byte((values[2] << 6) | values[3]))
                }
            }

            if values.count < 4 {
                // Short/padded group: it must be the last thing in the input.
                return onlyTrailingWhitespaceRemains()
            }
        }

        return hasDecodedAny || true
    }
}

// MARK: - Base32 Shared Implementation

extension RFC_4648 {
    /// Internal Base32 encoding implementation shared by Base32 and Base32.Hex
    ///
    /// - Parameters:
    ///   - bytes: The bytes to encode
    ///   - buffer: The buffer to append encoded characters to
    ///   - table: The encoding table to use (32 characters)
    ///   - padding: Whether to include padding characters
    @inlinable
    package static func encodeBase32<Bytes: Collection, Buffer: RangeReplaceableCollection>(
        _ bytes: Bytes,
        into buffer: inout Buffer,
        table: [ASCII.Code],
        padding: Bool
    ) where Bytes.Element == Byte, Buffer.Element == ASCII.Code {
        guard !bytes.isEmpty else { return }

        var iterator = bytes.makeIterator()

        while let b1Byte = iterator.next() {
            // Bridge Byte → UInt8 at iterator boundary for arithmetic.
            let b1 = b1Byte.underlying
            let b2 = iterator.next()?.underlying
            let b3 = iterator.next()?.underlying
            let b4 = iterator.next()?.underlying
            let b5 = iterator.next()?.underlying

            // First character: high 5 bits of b1
            buffer.append(table[Int((b1 >> 3) & 0x1F)])

            // Second character: low 2 bits of b1 + high 3 bits of b2
            let c2 = ((b1 << 2) | ((b2 ?? 0) >> 6)) & 0x1F
            buffer.append(table[Int(c2)])

            guard let b2 else {
                if padding {
                    buffer.append(contentsOf: [
                        RFC_4648.padding, RFC_4648.padding,
                        RFC_4648.padding, RFC_4648.padding,
                        RFC_4648.padding, RFC_4648.padding,
                    ])
                }
                break
            }

            // Third character: bits 5-1 of b2
            buffer.append(table[Int((b2 >> 1) & 0x1F)])

            // Fourth character: low 1 bit of b2 + high 4 bits of b3
            let c4 = ((b2 << 4) | ((b3 ?? 0) >> 4)) & 0x1F
            buffer.append(table[Int(c4)])

            guard let b3 else {
                if padding {
                    buffer.append(contentsOf: [
                        RFC_4648.padding, RFC_4648.padding,
                        RFC_4648.padding, RFC_4648.padding,
                    ])
                }
                break
            }

            // Fifth character: low 4 bits of b3 + high 1 bit of b4
            let c5 = ((b3 << 1) | ((b4 ?? 0) >> 7)) & 0x1F
            buffer.append(table[Int(c5)])

            guard let b4 else {
                if padding {
                    buffer.append(contentsOf: [
                        RFC_4648.padding, RFC_4648.padding, RFC_4648.padding,
                    ])
                }
                break
            }

            // Sixth character: bits 6-2 of b4
            buffer.append(table[Int((b4 >> 2) & 0x1F)])

            // Seventh character: low 2 bits of b4 + high 3 bits of b5
            let c7 = ((b4 << 3) | ((b5 ?? 0) >> 5)) & 0x1F
            buffer.append(table[Int(c7)])

            guard let b5 else {
                if padding {
                    buffer.append(RFC_4648.padding)
                }
                break
            }

            // Eighth character: low 5 bits of b5
            buffer.append(table[Int(b5 & 0x1F)])
        }
    }

    /// Internal Base32 decoding implementation shared by Base32 and Base32.Hex
    ///
    /// - Parameters:
    ///   - bytes: The encoded bytes to decode
    ///   - buffer: The buffer to append decoded bytes to
    ///   - decodeTable: The decoding table (256 entries, 255 = invalid)
    ///   - strictness: Whitespace/non-canonical-padding posture (default ``RFC_4648/Strictness/lenient``)
    /// - Returns: `true` if decoding succeeded, `false` if invalid input
    @inlinable
    @discardableResult
    package static func decodeBase32<Bytes: Collection, Buffer: RangeReplaceableCollection>(
        _ bytes: Bytes,
        into buffer: inout Buffer,
        decodeTable: [UInt8?],
        strictness: RFC_4648.Strictness = .lenient
    ) -> Bool where Bytes.Element == ASCII.Code, Buffer.Element == Byte {
        guard !bytes.isEmpty else { return true }

        var iterator = bytes.makeIterator()
        var values = [UInt8]()
        values.reserveCapacity(8)
        var hasDecodedAny = false

        // Once a short/padded (terminal) group has been processed, nothing but
        // whitespace may follow it — see decodeBase64's twin of this helper.
        // [F-001]
        func onlyTrailingWhitespaceRemains() -> Bool {
            while let code = iterator.next() {
                if strictness.rejectWhitespace || !code.isWhitespace { return false }
            }
            return true
        }

        while true {
            values.removeAll(keepingCapacity: true)
            var paddingCount = 0

            // Collect up to 8 quintets/padding characters for this group. Every
            // padding character is consumed here (not just the first one) so a
            // short data-bearing group can be validated against the *whole*
            // trailing padding run, not just its first character.
            while values.count + paddingCount < 8 {
                guard let code = iterator.next() else { break }
                if code == RFC_4648.padding {
                    paddingCount += 1
                    continue
                }
                if code.isWhitespace {
                    if strictness.rejectWhitespace { return false }
                    continue
                }
                // Padding in the middle is invalid
                if paddingCount > 0 { return false }
                guard let value = decodeTable[Int(code.underlying)] else { return false }
                values.append(value)
            }

            let totalChars = values.count + paddingCount

            // Handle end of input
            if totalChars == 0 { break }

            // A group made entirely of padding is never legal on its own —
            // padding only ever fills out the tail of a data-bearing group.
            if values.isEmpty { return false }

            // Only these quintet counts land on a whole-byte boundary; the
            // encoder never emits a remainder of 1, 3, or 6 quintets.
            guard
                values.count == 2 || values.count == 4 || values.count == 5
                    || values.count == 7 || values.count == 8
            else { return false }
            hasDecodedAny = true

            // A short final group leaves some low bits of its last quintet
            // unused. Canonical encoders always emit zero there; see the
            // matching check in decodeBase64.
            if strictness.rejectNonzeroTrailingBits {
                switch values.count {
                case 2 where (values[1] & 0x03) != 0: return false
                case 4 where (values[3] & 0x0F) != 0: return false
                case 5 where (values[4] & 0x01) != 0: return false
                case 7 where (values[6] & 0x07) != 0: return false
                default: break
                }
            }

            // First byte: 5 bits from v1 + high 3 bits from v2
            buffer.append(Byte((values[0] << 3) | (values[1] >> 2)))

            if values.count >= 4 {
                // Second byte
                buffer.append(Byte((values[1] << 6) | (values[2] << 1) | (values[3] >> 4)))
            }

            if values.count >= 5 {
                // Third byte
                buffer.append(Byte((values[3] << 4) | (values[4] >> 1)))
            }

            if values.count >= 7 {
                // Fourth byte
                buffer.append(Byte((values[4] << 7) | (values[5] << 2) | (values[6] >> 3)))
            }

            if values.count >= 8 {
                // Fifth byte
                buffer.append(Byte((values[6] << 5) | values[7]))
            }

            if values.count < 8 {
                // Short/padded group: it must be the last thing in the input.
                return onlyTrailingWhitespaceRemains()
            }
        }

        return hasDecodedAny || true
    }
}
