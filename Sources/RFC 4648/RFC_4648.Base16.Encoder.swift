import ASCII
public import Binary

extension RFC_4648.Base16 {

    public struct Encoder: Sendable {
        @inlinable
        public init() {}
    }
}

extension RFC_4648.Base16.Encoder {

    @inlinable
    public func callAsFunction<Bytes: Collection>(
        _ bytes: Bytes,
        uppercase: Bool = false
    ) -> String where Bytes.Element == Byte {
        let encoded: [ASCII.Code] = RFC_4648.Base16.encode(bytes, uppercase: uppercase)
        return String(decoding: encoded, as: UTF8.self)
    }

    @inlinable
    public func callAsFunction<T: FixedWidthInteger>(
        _ value: T,
        prefix: String = "0x",
        uppercase: Bool = false
    ) -> String {
        prefix + callAsFunction(value.bytes(endianness: .big), uppercase: uppercase)
    }
}
