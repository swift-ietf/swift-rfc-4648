import ASCII
public import Binary_Standard_Library_Integration

extension RFC_4648 {

    public enum Base16 {

        public struct Wrapper<Wrapped> {
            public let wrapped: Wrapped

            @inlinable
            public init(_ wrapped: Wrapped) {
                self.wrapped = wrapped
            }
        }
    }
}

extension RFC_4648.Base16 {

    public static let encodingTable = RFC_4648.EncodingTable(
        encode: (0...15).map { ASCII.Hexadecimal.code(UInt8($0), case: .lower)! },
        caseInsensitive: true
    )

    public static let encodingTableUppercase = RFC_4648.EncodingTable(
        encode: (0...15).map { ASCII.Hexadecimal.code(UInt8($0), case: .upper)! },
        caseInsensitive: true
    )
}

extension RFC_4648.Base16 {

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

            let code =
                uppercase
                ? ASCII.Hexadecimal.code(UInt8(nibble), case: .upper)!
                : ASCII.Hexadecimal.code(UInt8(nibble), case: .lower)!

            if suppressLeadingZeros {
                if nibble != 0 {
                    foundNonZero = true
                }

                if foundNonZero || i == 0 {
                    buffer.append(code)
                }
            } else {
                buffer.append(code)
            }
        }
    }

    @inlinable
    public static func encode<Bytes: Collection, Buffer: RangeReplaceableCollection>(
        _ bytes: Bytes,
        into buffer: inout Buffer,
        uppercase: Bool = false
    ) where Bytes.Element == Byte, Buffer.Element == ASCII.Code {
        for byte in bytes {

            encode(
                byte.bitPattern,
                into: &buffer,
                uppercase: uppercase,
                suppressLeadingZeros: false
            )
        }
    }

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

extension RFC_4648.Base16 {

    @inlinable
    public static func decode(nibble: ASCII.Code) -> UInt8? {

        nibble.hexValue
    }

    @inlinable
    public static func decode(high: ASCII.Code, low: ASCII.Code) -> UInt8? {
        guard let highNibble = decode(nibble: high),
            let lowNibble = decode(nibble: low)
        else { return nil }
        return (highNibble << 4) | lowNibble
    }

    @inlinable
    @discardableResult
    public static func decode<Bytes: Collection, Buffer: RangeReplaceableCollection>(
        _ bytes: Bytes,
        into buffer: inout Buffer,
        skipPrefix: Bool = true
    ) -> Bool where Bytes.Element == ASCII.Code, Buffer.Element == Byte {
        guard !bytes.isEmpty else { return true }

        var iterator = bytes.makeIterator()

        func nextSignificant() -> ASCII.Code? {
            while let code = iterator.next() {
                if !code.isWhitespace { return code }
            }
            return nil
        }

        var pending = nextSignificant()

        if skipPrefix, let first = pending, first == ASCII.Code.`0` {
            guard let second = nextSignificant() else {

                return false
            }
            if second == ASCII.Code.x || second == ASCII.Code.X {

                pending = nextSignificant()
            } else {

                guard let highNibble = decode(nibble: first), let lowNibble = decode(nibble: second)
                else {
                    return false
                }
                buffer.append(Byte(bitPattern: (highNibble << 4) | lowNibble))
                pending = nextSignificant()
            }
        }

        while let high = pending {
            guard let low = nextSignificant() else { return false }
            guard let highNibble = decode(nibble: high), let lowNibble = decode(nibble: low) else {
                return false
            }
            buffer.append(Byte(bitPattern: (highNibble << 4) | lowNibble))
            pending = nextSignificant()
        }

        return true
    }

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

    @inlinable
    public static func decode(
        _ string: some StringProtocol,
        skipPrefix: Bool = true
    ) -> [Byte]? {
        var codes: [ASCII.Code] = []
        for unit in string.utf8 {
            guard let code = try? ASCII.Code(Byte(bitPattern: unit)) else {
                return nil
            }
            codes.append(code)
        }
        return decode(codes, skipPrefix: skipPrefix)
    }

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

        if skipPrefix {
            guard let first = iterator.next() else { return 0 }

            if first == ASCII.Code.`0` {
                if let second = iterator.next() {
                    if second == ASCII.Code.x || second == ASCII.Code.X {

                    } else if !second.isWhitespace {

                        guard let highNibble = decode(nibble: first),
                            let lowNibble = decode(nibble: second)
                        else { return nil }
                        result = T(highNibble) << 4 | T(lowNibble)
                        nibbleCount = 2
                    } else {

                        guard let nibble = decode(nibble: first) else { return nil }
                        result = T(nibble)
                        nibbleCount = 1
                    }
                } else {

                    return 0
                }
            } else if !first.isWhitespace {
                guard let nibble = decode(nibble: first) else { return nil }
                result = T(nibble)
                nibbleCount = 1
            }
        }

        while let code = iterator.next() {
            guard !code.isWhitespace else { continue }

            guard let nibble = decode(nibble: code) else { return nil }

            nibbleCount += 1
            guard nibbleCount <= maxNibbles else { return nil }

            result = result << 4 | T(nibble)
        }

        return result
    }
}

extension RFC_4648.Base16.Wrapper where Wrapped: Collection, Wrapped.Element == Byte {

    @inlinable
    public func encode<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer,
        uppercase: Bool = false
    ) where Buffer.Element == ASCII.Code {
        RFC_4648.Base16.encode(wrapped, into: &buffer, uppercase: uppercase)
    }

    @inlinable
    public func encoded(uppercase: Bool = false) -> String {
        let codes: [ASCII.Code] = RFC_4648.Base16.encode(wrapped, uppercase: uppercase)
        return String(decoding: codes.map(\.underlying), as: UTF8.self)
    }

    @inlinable
    public func callAsFunction(uppercase: Bool = false) -> String {
        encoded(uppercase: uppercase)
    }
}

extension RFC_4648.Base16.Wrapper where Wrapped: Collection, Wrapped.Element == ASCII.Code {

    @inlinable
    @discardableResult
    public func decode<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer,
        skipPrefix: Bool = true
    ) -> Bool where Buffer.Element == Byte {
        RFC_4648.Base16.decode(wrapped, into: &buffer, skipPrefix: skipPrefix)
    }

    @inlinable
    public func decoded(skipPrefix: Bool = true) -> [Byte]? {
        RFC_4648.Base16.decode(wrapped, skipPrefix: skipPrefix)
    }

    @inlinable
    public func decoded<T: FixedWidthInteger>(
        as type: T.Type = T.self,
        skipPrefix: Bool = true
    ) -> T? {
        RFC_4648.Base16.decode(wrapped, as: type, skipPrefix: skipPrefix)
    }
}

extension RFC_4648.Base16.Wrapper where Wrapped: StringProtocol {

    @inlinable
    @discardableResult
    public func decode<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer,
        skipPrefix: Bool = true
    ) -> Bool where Buffer.Element == Byte {
        var codes: [ASCII.Code] = []
        for unit in wrapped.utf8 {
            guard let code = try? ASCII.Code(Byte(bitPattern: unit)) else {
                return false
            }
            codes.append(code)
        }
        return RFC_4648.Base16.decode(codes, into: &buffer, skipPrefix: skipPrefix)
    }

    @inlinable
    public func decoded(skipPrefix: Bool = true) -> [Byte]? {
        RFC_4648.Base16.decode(wrapped, skipPrefix: skipPrefix)
    }

    @inlinable
    public func decoded<T: FixedWidthInteger>(
        as type: T.Type = T.self,
        skipPrefix: Bool = true
    ) -> T? {
        var codes: [ASCII.Code] = []
        for unit in wrapped.utf8 {
            guard let code = try? ASCII.Code(Byte(bitPattern: unit)) else {
                return nil
            }
            codes.append(code)
        }
        return RFC_4648.Base16.decode(codes, as: type, skipPrefix: skipPrefix)
    }
}

extension RFC_4648 {

    public typealias Hex = Base16
}
