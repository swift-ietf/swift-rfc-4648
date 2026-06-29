//
//  RFC_4648.Base16.swift
//  swift-rfc-4648
//
//  Base16 (Hexadecimal) encoding per RFC 4648 Section 8

import ASCII_Primitives
public import Binary_Primitives

// MARK: - Base16 Type

extension RFC_4648 {
    /// Base16 (hexadecimal) encoding (RFC 4648 Section 8)
    ///
    /// RFC 4648 Section 8 defines "Base 16 Encoding" as the canonical name.
    /// Commonly known as hexadecimal or hex encoding.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Static methods (authoritative)
    /// RFC_4648.Base16.encode(segment, into: &buffer, suppressLeadingZeros: true)
    /// let decoded = RFC_4648.Base16.decode("deadbeef")
    ///
    /// // Instance methods (convenience)
    /// bytes.hex.encoded()
    /// "deadbeef".hex.decoded()
    /// ```
    public enum Base16 {
        /// Wrapper for instance-based convenience methods
        public struct Wrapper<Wrapped> {
            public let wrapped: Wrapped

            @inlinable
            public init(_ wrapped: Wrapped) {
                self.wrapped = wrapped
            }
        }
    }
}

// MARK: - Encoding Tables

extension RFC_4648.Base16 {
    /// Base16 lowercase encoding table (RFC 4648 Section 8).
    ///
    /// The hex alphabet is derived from the L1 ASCII single-byte primitive
    /// `ASCII.Hexadecimal.code(_:case:)` — L1 is the single source of
    /// truth — and the decode table is case-insensitive (accepts upper + lower),
    /// matching the historical shared hex decode table. Kept public for parity
    /// with the Base32/Base64 `encodingTable` family.
    public static let encodingTable = RFC_4648.EncodingTable(
        encode: (0...15).map { ASCII.Hexadecimal.code(UInt8($0), case: .lower)! },
        caseInsensitive: true
    )

    /// Base16 uppercase encoding table (RFC 4648 Section 8).
    ///
    /// Uppercase counterpart of ``encodingTable``; alphabet derived from
    /// `ASCII.Hexadecimal.code(_:case:)`.
    public static let encodingTableUppercase = RFC_4648.EncodingTable(
        encode: (0...15).map { ASCII.Hexadecimal.code(UInt8($0), case: .upper)! },
        caseInsensitive: true
    )
}

// MARK: - Static Encode Methods (Authoritative)

extension RFC_4648.Base16 {
    /// Encodes an integer value to Base16 (hexadecimal) into a buffer (PRIMITIVE)
    ///
    /// This is the fundamental encoding operation. All other encode methods
    /// delegate to this implementation.
    ///
    /// - Parameters:
    ///   - value: The integer value to encode
    ///   - buffer: The buffer to append hex ASCII codes to
    ///   - uppercase: Whether to use uppercase hex digits (default: false)
    ///   - suppressLeadingZeros: Whether to suppress leading zeros (default: false)
    @inlinable
    public static func encode<Buffer: RangeReplaceableCollection, T: FixedWidthInteger>(
        _ value: T,
        into buffer: inout Buffer,
        uppercase: Bool = false,
        suppressLeadingZeros: Bool = false
    ) where Buffer.Element == ASCII.Code {
        let nibbleCount = T.bitWidth / 4

        var foundNonZero = false

        for i in (0..<nibbleCount).reversed() {
            let nibble = Int((value >> (i * 4)) & 0x0F)

            // Delegate the nibble → ASCII.Code mapping to the L1 single-byte ASCII
            // serialization primitives so the hex alphabet has a single source of
            // truth. The nibble is masked to 0...15, so the force-unwrap is total.
            let code = uppercase
                ? ASCII.Hexadecimal.code(UInt8(nibble), case: .upper)!
                : ASCII.Hexadecimal.code(UInt8(nibble), case: .lower)!

            if suppressLeadingZeros {
                if nibble != 0 {
                    foundNonZero = true
                }
                // Always output if: non-zero found, or last nibble (ensure at least "0")
                if foundNonZero || i == 0 {
                    buffer.append(code)
                }
            } else {
                buffer.append(code)
            }
        }
    }

    /// Encodes bytes to Base16 into a buffer
    ///
    /// Each byte is encoded as exactly 2 hex characters.
    @inlinable
    public static func encode<Bytes: Collection, Buffer: RangeReplaceableCollection>(
        _ bytes: Bytes,
        into buffer: inout Buffer,
        uppercase: Bool = false
    ) where Bytes.Element == Byte, Buffer.Element == ASCII.Code {
        for byte in bytes {
            // Bridge Byte → UInt8 at the iterator boundary so the integer
            // overload's arithmetic shifts operate in the arithmetic domain.
            encode(byte.underlying, into: &buffer, uppercase: uppercase, suppressLeadingZeros: false)
        }
    }

    /// Encodes bytes to Base16, returning a new collection
    ///
    /// Convenience method that creates a buffer and returns it.
    @inlinable
    public static func encode<Bytes: Collection, Result: RangeReplaceableCollection>(
        _ bytes: Bytes,
        uppercase: Bool = false
    ) -> Result where Bytes.Element == Byte, Result.Element == ASCII.Code {
        var result = Result()
        encode(bytes, into: &result, uppercase: uppercase)
        return result
    }
}

// MARK: - Static Decode Methods (Authoritative)

extension RFC_4648.Base16 {
    /// Decodes a single hex character to its nibble value (PRIMITIVE)
    ///
    /// - Parameter nibble: ASCII code of hex character ('0'-'9', 'a'-'f', 'A'-'F')
    /// - Returns: Nibble value (0-15), or nil if invalid. Value is arithmetic-domain
    ///   UInt8 per [API-BYTE-004] Q3 rubric.
    ///
    /// ## Example
    ///
    /// ```swift
    /// RFC_4648.Base16.decode(nibble: .a)  // 10
    /// RFC_4648.Base16.decode(nibble: .F)  // 15
    /// RFC_4648.Base16.decode(nibble: .g)  // nil
    /// ```
    @inlinable
    public static func decode(nibble: ASCII.Code) -> UInt8? {
        // Single source of truth: the L1 single-byte ASCII parsing primitive owns
        // the hex-digit → nibble mapping (case-insensitive). Every higher decode
        // overload funnels through this method.
        nibble.hexValue
    }

    /// Decodes a hex pair to a single byte (PRIMITIVE)
    @inlinable
    public static func decode(high: ASCII.Code, low: ASCII.Code) -> UInt8? {
        guard let highNibble = decode(nibble: high),
              let lowNibble = decode(nibble: low) else { return nil }
        return (highNibble << 4) | lowNibble
    }

    /// Decodes Base16 ASCII codes into a buffer (streaming, no allocation)
    ///
    /// - Parameters:
    ///   - bytes: Base16 encoded ASCII codes (must have even count after whitespace removal)
    ///   - buffer: The buffer to append decoded bytes to
    ///   - skipPrefix: Whether to skip "0x" or "0X" prefix (default: true)
    /// - Returns: `true` if decoding succeeded, `false` if invalid input
    @inlinable
    @discardableResult
    public static func decode<Bytes: Collection, Buffer: RangeReplaceableCollection>(
        _ bytes: Bytes,
        into buffer: inout Buffer,
        skipPrefix: Bool = true
    ) -> Bool where Bytes.Element == ASCII.Code, Buffer.Element == Byte {
        guard !bytes.isEmpty else { return true }

        var iterator = bytes.makeIterator()

        // Check for "0x" or "0X" prefix
        if skipPrefix {
            // Peek at first two ASCII codes
            guard let first = iterator.next() else { return true }

            if first == ASCII.Code.`0` {
                guard let second = iterator.next() else {
                    // Just "0" - decode as single zero nibble? No, need pairs.
                    // Single '0' is invalid for byte decoding
                    return false
                }
                if second != ASCII.Code.x && second != ASCII.Code.X {
                    // Not a prefix, these are actual hex digits
                    // Decode this pair
                    guard let highNibble = decode(nibble: first),
                          let lowNibble = decode(nibble: second) else { return false }
                    buffer.append(Byte((highNibble << 4) | lowNibble))
                }
                // If it was "0x"/"0X", we consumed it and continue
            } else {
                // First code is not '0', need to pair it with next
                guard let second = iterator.next() else { return false }
                // Skip whitespace for first code
                var high = first
                while high.isWhitespace {
                    guard let next = iterator.next() else { return false }
                    high = next
                }
                var low = second
                while low.isWhitespace {
                    guard let next = iterator.next() else { return false }
                    low = next
                }
                guard let highNibble = decode(nibble: high),
                      let lowNibble = decode(nibble: low) else { return false }
                buffer.append(Byte((highNibble << 4) | lowNibble))
            }
        }

        // Process remaining pairs
        while let high = iterator.next() {
            // Skip whitespace
            var highCode = high
            while highCode.isWhitespace {
                guard let next = iterator.next() else { return true }  // trailing whitespace ok
                highCode = next
            }

            guard let low = iterator.next() else { return false }  // odd number of hex chars

            var lowCode = low
            while lowCode.isWhitespace {
                guard let next = iterator.next() else { return false }
                lowCode = next
            }

            guard let highNibble = decode(nibble: highCode),
                  let lowNibble = decode(nibble: lowCode) else { return false }
            buffer.append(Byte((highNibble << 4) | lowNibble))
        }

        return true
    }

    /// Decodes Base16 encoded ASCII codes to a new byte array
    @inlinable
    public static func decode<Bytes: Collection>(
        _ bytes: Bytes,
        skipPrefix: Bool = true
    ) -> [Byte]? where Bytes.Element == ASCII.Code {
        var result: [Byte] = []
        result.reserveCapacity(bytes.count / 2)
        guard decode(bytes, into: &result, skipPrefix: skipPrefix) else { return nil }
        return result
    }

    /// Decodes Base16 encoded string (case-insensitive)
    ///
    /// Lifts `string.utf8` to the `ASCII.Code` substrate at entry.
    /// Returns `nil` if the string contains non-ASCII bytes.
    @inlinable
    public static func decode(
        _ string: some StringProtocol,
        skipPrefix: Bool = true
    ) -> [Byte]? {
        let codes: [ASCII.Code]
        do {
            codes = try Array<ASCII.Code>(string.utf8)
        } catch {
            return nil
        }
        return decode(codes, skipPrefix: skipPrefix)
    }

    /// Decodes Base16 to a FixedWidthInteger (PRIMITIVE)
    ///
    /// Decodes hex ASCII codes directly to an integer value without intermediate array allocation.
    @inlinable
    public static func decode<Bytes: Collection, T: FixedWidthInteger>(
        _ bytes: Bytes,
        as type: T.Type = T.self,
        skipPrefix: Bool = true
    ) -> T? where Bytes.Element == ASCII.Code {
        guard !bytes.isEmpty else { return 0 }

        var iterator = bytes.makeIterator()
        var result: T = 0
        var nibbleCount = 0
        let maxNibbles = T.bitWidth / 4

        // Check for "0x" or "0X" prefix
        if skipPrefix {
            guard let first = iterator.next() else { return 0 }

            if first == ASCII.Code.`0` {
                if let second = iterator.next() {
                    if second == ASCII.Code.x || second == ASCII.Code.X {
                        // Prefix consumed, continue
                    } else if !second.isWhitespace {
                        // Not a prefix, these are hex digits
                        guard let highNibble = decode(nibble: first),
                              let lowNibble = decode(nibble: second) else { return nil }
                        result = T(highNibble) << 4 | T(lowNibble)
                        nibbleCount = 2
                    } else {
                        // '0' followed by whitespace - just '0'
                        guard let nibble = decode(nibble: first) else { return nil }
                        result = T(nibble)
                        nibbleCount = 1
                    }
                } else {
                    // Just "0"
                    return 0
                }
            } else if !first.isWhitespace {
                guard let nibble = decode(nibble: first) else { return nil }
                result = T(nibble)
                nibbleCount = 1
            }
        }

        // Process remaining nibbles
        while let code = iterator.next() {
            guard !code.isWhitespace else { continue }

            guard let nibble = decode(nibble: code) else { return nil }

            nibbleCount += 1
            guard nibbleCount <= maxNibbles else { return nil }  // overflow

            result = result << 4 | T(nibble)
        }

        return result
    }
}

// MARK: - Instance Methods (Convenience) - Encode (raw bytes IN)

extension RFC_4648.Base16.Wrapper where Wrapped: Collection, Wrapped.Element == Byte {
    /// Encodes wrapped bytes to Base16 into a buffer
    @inlinable
    public func encode<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer,
        uppercase: Bool = false
    ) where Buffer.Element == ASCII.Code {
        RFC_4648.Base16.encode(wrapped, into: &buffer, uppercase: uppercase)
    }

    /// Encodes wrapped bytes to hexadecimal string
    @inlinable
    public func encoded(uppercase: Bool = false) -> String {
        let codes: [ASCII.Code] = RFC_4648.Base16.encode(wrapped, uppercase: uppercase)
        return String(decoding: codes, as: UTF8.self)
    }

    /// Encodes wrapped bytes to hexadecimal string (callable syntax)
    @inlinable
    public func callAsFunction(uppercase: Bool = false) -> String {
        encoded(uppercase: uppercase)
    }
}

// MARK: - Instance Methods (Convenience) - Decode (encoded ASCII codes IN)

extension RFC_4648.Base16.Wrapper where Wrapped: Collection, Wrapped.Element == ASCII.Code {
    /// Decodes wrapped hex-encoded ASCII codes into a buffer
    @inlinable
    @discardableResult
    public func decode<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer,
        skipPrefix: Bool = true
    ) -> Bool where Buffer.Element == Byte {
        RFC_4648.Base16.decode(wrapped, into: &buffer, skipPrefix: skipPrefix)
    }

    /// Decodes wrapped hex-encoded ASCII codes to raw bytes
    @inlinable
    public func decoded(skipPrefix: Bool = true) -> [Byte]? {
        RFC_4648.Base16.decode(wrapped, skipPrefix: skipPrefix)
    }

    /// Decodes wrapped hex-encoded ASCII codes to a FixedWidthInteger
    @inlinable
    public func decoded<T: FixedWidthInteger>(
        as type: T.Type = T.self,
        skipPrefix: Bool = true
    ) -> T? {
        RFC_4648.Base16.decode(wrapped, as: type, skipPrefix: skipPrefix)
    }
}

// MARK: - Instance Methods (Convenience) - String

extension RFC_4648.Base16.Wrapper where Wrapped: StringProtocol {
    /// Decodes wrapped hexadecimal string into a buffer.
    ///
    /// Returns `false` if the string contains non-ASCII bytes.
    @inlinable
    @discardableResult
    public func decode<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer,
        skipPrefix: Bool = true
    ) -> Bool where Buffer.Element == Byte {
        let codes: [ASCII.Code]
        do {
            codes = try Array<ASCII.Code>(wrapped.utf8)
        } catch {
            return false
        }
        return RFC_4648.Base16.decode(codes, into: &buffer, skipPrefix: skipPrefix)
    }

    /// Decodes wrapped hexadecimal string to bytes
    @inlinable
    public func decoded(skipPrefix: Bool = true) -> [Byte]? {
        RFC_4648.Base16.decode(wrapped, skipPrefix: skipPrefix)
    }

    /// Decodes wrapped hexadecimal string to a FixedWidthInteger.
    ///
    /// Returns `nil` if the string contains non-ASCII bytes.
    @inlinable
    public func decoded<T: FixedWidthInteger>(
        as type: T.Type = T.self,
        skipPrefix: Bool = true
    ) -> T? {
        let codes: [ASCII.Code]
        do {
            codes = try Array<ASCII.Code>(wrapped.utf8)
        } catch {
            return nil
        }
        return RFC_4648.Base16.decode(codes, as: type, skipPrefix: skipPrefix)
    }
}

// MARK: - Typealias

extension RFC_4648 {
    /// Ergonomic typealias for Base16 encoding
    ///
    /// While RFC 4648 Section 8 officially names this "Base 16 Encoding",
    /// it's commonly known as hexadecimal. This typealias provides familiar ergonomics.
    public typealias Hex = Base16
}
