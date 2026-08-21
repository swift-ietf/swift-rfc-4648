import ASCII_Primitives
public import Binary_Primitives

extension RFC_4648.Base64 {

    public enum URL {

        public struct Wrapper<Wrapped> {
            public let wrapped: Wrapped

            @inlinable
            public init(_ wrapped: Wrapped) {
                self.wrapped = wrapped
            }
        }
    }
}

extension RFC_4648.Base64.URL {

    public static let encodingTable = RFC_4648.EncodingTable(
        encode: [
            .A, .B, .C, .D, .E, .F, .G, .H,
            .I, .J, .K, .L, .M, .N, .O, .P,
            .Q, .R, .S, .T, .U, .V, .W, .X,
            .Y, .Z, .a, .b, .c, .d, .e, .f,
            .g, .h, .i, .j, .k, .l, .m, .n,
            .o, .p, .q, .r, .s, .t, .u, .v,
            .w, .x, .y, .z, .`0`, .`1`, .`2`, .`3`,
            .`4`, .`5`, .`6`, .`7`, .`8`, .`9`, .hyphen, .underscore,
        ] as [ASCII.Code]
    )
}

extension RFC_4648.Base64.URL {

    @inlinable
    public static func encode<Bytes: Collection, Buffer: RangeReplaceableCollection>(
        _ bytes: Bytes,
        into buffer: inout Buffer,
        padding: Bool = false
    ) where Bytes.Element == Byte, Buffer.Element == ASCII.Code {
        RFC_4648.encodeBase64(bytes, into: &buffer, table: encodingTable.encode, padding: padding)
    }

    @inlinable
    public static func encode<Bytes: Collection>(
        _ bytes: Bytes,
        padding: Bool = false
    ) -> [ASCII.Code] where Bytes.Element == Byte {
        var result: [ASCII.Code] = []
        result.reserveCapacity(((bytes.count + 2) / 3) * 4)
        encode(bytes, into: &result, padding: padding)
        return result
    }
}

extension RFC_4648.Base64.URL {

    @inlinable
    public static func decode(sextet: ASCII.Code) -> UInt8? {
        encodingTable.decode[Int(sextet.underlying)]
    }

    @inlinable
    @discardableResult
    public static func decode<Bytes: Collection, Buffer: RangeReplaceableCollection>(
        _ bytes: Bytes,
        into buffer: inout Buffer,
        strictness: RFC_4648.Strictness = .lenient
    ) -> Bool where Bytes.Element == ASCII.Code, Buffer.Element == Byte {
        RFC_4648.decodeBase64(
            bytes,
            into: &buffer,
            decodeTable: encodingTable.decode,
            requirePadding: false,
            strictness: strictness
        )
    }

    @inlinable
    public static func decode<Bytes: Collection>(
        _ bytes: Bytes,
        strictness: RFC_4648.Strictness = .lenient
    ) -> [Byte]? where Bytes.Element == ASCII.Code {
        var result: [Byte] = []
        result.reserveCapacity((bytes.count * 3) / 4)
        guard decode(bytes, into: &result, strictness: strictness) else { return nil }
        return result
    }

    @inlinable
    public static func decode(
        _ string: some StringProtocol,
        strictness: RFC_4648.Strictness = .lenient
    ) -> [Byte]? {
        let codes: [ASCII.Code]
        do throws(ASCII.Code.Error) {
            codes = try [ASCII.Code](string.utf8)
        } catch {
            return nil
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

extension RFC_4648.Base64.URL.Wrapper where Wrapped: Collection, Wrapped.Element == Byte {

    @inlinable
    public func encode<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer,
        padding: Bool = false
    ) where Buffer.Element == ASCII.Code {
        RFC_4648.Base64.URL.encode(wrapped, into: &buffer, padding: padding)
    }

    @inlinable
    public func encoded(padding: Bool = false) -> String {
        String(decoding: RFC_4648.Base64.URL.encode(wrapped, padding: padding), as: UTF8.self)
    }

    @inlinable
    public func callAsFunction(padding: Bool = false) -> String {
        encoded(padding: padding)
    }
}

extension RFC_4648.Base64.URL.Wrapper where Wrapped: Collection, Wrapped.Element == ASCII.Code {

    @inlinable
    @discardableResult
    public func decode<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer,
        strictness: RFC_4648.Strictness = .lenient
    ) -> Bool where Buffer.Element == Byte {
        RFC_4648.Base64.URL.decode(wrapped, into: &buffer, strictness: strictness)
    }

    @inlinable
    public func decoded(strictness: RFC_4648.Strictness = .lenient) -> [Byte]? {
        RFC_4648.Base64.URL.decode(wrapped, strictness: strictness)
    }

    @inlinable
    public func decoded<T: FixedWidthInteger>(as type: T.Type = T.self) -> T? {
        RFC_4648.Base64.URL.decode(wrapped, as: type)
    }
}

extension RFC_4648.Base64.URL.Wrapper where Wrapped: StringProtocol {

    @inlinable
    @discardableResult
    public func decode<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer,
        strictness: RFC_4648.Strictness = .lenient
    ) -> Bool where Buffer.Element == Byte {
        let codes: [ASCII.Code]
        do throws(ASCII.Code.Error) {
            codes = try [ASCII.Code](wrapped.utf8)
        } catch {
            return false
        }
        return RFC_4648.Base64.URL.decode(codes, into: &buffer, strictness: strictness)
    }

    @inlinable
    public func decoded(strictness: RFC_4648.Strictness = .lenient) -> [Byte]? {
        RFC_4648.Base64.URL.decode(wrapped, strictness: strictness)
    }

    @inlinable
    public func decoded<T: FixedWidthInteger>(as type: T.Type = T.self) -> T? {
        let codes: [ASCII.Code]
        do throws(ASCII.Code.Error) {
            codes = try [ASCII.Code](wrapped.utf8)
        } catch {
            return nil
        }
        return RFC_4648.Base64.URL.decode(codes, as: type)
    }
}
