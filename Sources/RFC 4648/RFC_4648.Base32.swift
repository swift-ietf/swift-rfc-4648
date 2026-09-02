import ASCII
public import Binary_Endianness
public import Binary_Standard_Library_Integration

extension RFC_4648 {

    public enum Base32 {

        public struct Wrapper<Wrapped> {
            public let wrapped: Wrapped

            @inlinable
            public init(_ wrapped: Wrapped) {
                self.wrapped = wrapped
            }
        }
    }
}

extension RFC_4648.Base32 {

    public static let encodingTable = RFC_4648.EncodingTable(
        encode: [
            .A, .B, .C, .D, .E, .F, .G, .H,
            .I, .J, .K, .L, .M, .N, .O, .P,
            .Q, .R, .S, .T, .U, .V, .W, .X,
            .Y, .Z, .`2`, .`3`, .`4`, .`5`, .`6`, .`7`,
        ] as [ASCII.Code],
        caseInsensitive: true
    )
}

extension RFC_4648.Base32 {

    @inlinable
    public static func encode<Bytes: Collection, Buffer: RangeReplaceableCollection>(
        _ bytes: Bytes,
        into buffer: inout Buffer,
        padding: Bool = true
    ) where Bytes.Element == Byte, Buffer.Element == ASCII.Code {
        RFC_4648.encodeBase32(bytes, into: &buffer, table: encodingTable.encode, padding: padding)
    }

    @inlinable
    public static func encode<Bytes: Collection>(
        _ bytes: Bytes,
        padding: Bool = true
    ) -> [ASCII.Code] where Bytes.Element == Byte {
        var result: [ASCII.Code] = []
        result.reserveCapacity(((bytes.count + 4) / 5) * 8)
        encode(bytes, into: &result, padding: padding)
        return result
    }
}

extension RFC_4648.Base32 {

    @inlinable
    public static func decode(quintet: ASCII.Code) -> UInt8? {
        encodingTable.decode[Int(quintet.underlying)]
    }

    @inlinable
    @discardableResult
    public static func decode<Bytes: Collection, Buffer: RangeReplaceableCollection>(
        _ bytes: Bytes,
        into buffer: inout Buffer,
        strictness: RFC_4648.Strictness = .lenient
    ) -> Bool where Bytes.Element == ASCII.Code, Buffer.Element == Byte {
        RFC_4648.decodeBase32(
            bytes,
            into: &buffer,
            decodeTable: encodingTable.decode,
            strictness: strictness
        )
    }

    @inlinable
    public static func decode<Bytes: Collection>(
        _ bytes: Bytes,
        strictness: RFC_4648.Strictness = .lenient
    ) -> [Byte]? where Bytes.Element == ASCII.Code {
        var result: [Byte] = []
        result.reserveCapacity((bytes.count * 5) / 8)
        guard decode(bytes, into: &result, strictness: strictness) else { return nil }
        return result
    }

    @inlinable
    public static func decode(
        _ string: some StringProtocol,
        strictness: RFC_4648.Strictness = .lenient
    ) -> [Byte]? {
        var codes: [ASCII.Code] = []
        for unit in string.utf8 {
            guard let code = try? ASCII.Code(Byte(bitPattern: unit)) else {
                return nil
            }
            codes.append(code)
        }
        return decode(codes, strictness: strictness)
    }

    @inlinable
    public static func decode<Bytes: Collection, T: FixedWidthInteger>(
        _ bytes: Bytes,
        as type: T.Type = T.self
    ) -> T? where Bytes.Element == ASCII.Code {
        guard let decodedBytes = decode(bytes) else { return nil }
        return T(bytes: decodedBytes, endianness: .big)
    }
}

extension RFC_4648.Base32.Wrapper {

    @inlinable
    public var hex: RFC_4648.Base32.Hex.Wrapper<Wrapped> {
        RFC_4648.Base32.Hex.Wrapper(wrapped)
    }
}

extension RFC_4648.Base32.Wrapper where Wrapped: Collection, Wrapped.Element == Byte {

    @inlinable
    public func encode<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer,
        padding: Bool = true
    ) where Buffer.Element == ASCII.Code {
        RFC_4648.Base32.encode(wrapped, into: &buffer, padding: padding)
    }

    @inlinable
    public func encoded(padding: Bool = true) -> String {
        let codes: [ASCII.Code] = RFC_4648.Base32.encode(wrapped, padding: padding)
        return String(decoding: codes.map(\.underlying), as: UTF8.self)
    }

    @inlinable
    public func callAsFunction(padding: Bool = true) -> String {
        encoded(padding: padding)
    }
}

extension RFC_4648.Base32.Wrapper where Wrapped: Collection, Wrapped.Element == ASCII.Code {

    @inlinable
    @discardableResult
    public func decode<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer,
        strictness: RFC_4648.Strictness = .lenient
    ) -> Bool where Buffer.Element == Byte {
        RFC_4648.Base32.decode(wrapped, into: &buffer, strictness: strictness)
    }

    @inlinable
    public func decoded(strictness: RFC_4648.Strictness = .lenient) -> [Byte]? {
        RFC_4648.Base32.decode(wrapped, strictness: strictness)
    }

    @inlinable
    public func decoded<T: FixedWidthInteger>(as type: T.Type = T.self) -> T? {
        RFC_4648.Base32.decode(wrapped, as: type)
    }
}

extension RFC_4648.Base32.Wrapper where Wrapped: StringProtocol {

    @inlinable
    @discardableResult
    public func decode<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer,
        strictness: RFC_4648.Strictness = .lenient
    ) -> Bool where Buffer.Element == Byte {
        var codes: [ASCII.Code] = []
        for unit in wrapped.utf8 {
            guard let code = try? ASCII.Code(Byte(bitPattern: unit)) else {
                return false
            }
            codes.append(code)
        }
        return RFC_4648.Base32.decode(codes, into: &buffer, strictness: strictness)
    }

    @inlinable
    public func decoded(strictness: RFC_4648.Strictness = .lenient) -> [Byte]? {
        RFC_4648.Base32.decode(wrapped, strictness: strictness)
    }

    @inlinable
    public func decoded<T: FixedWidthInteger>(as type: T.Type = T.self) -> T? {
        var codes: [ASCII.Code] = []
        for unit in wrapped.utf8 {
            guard let code = try? ASCII.Code(Byte(bitPattern: unit)) else {
                return nil
            }
            codes.append(code)
        }
        return RFC_4648.Base32.decode(codes, as: type)
    }
}
