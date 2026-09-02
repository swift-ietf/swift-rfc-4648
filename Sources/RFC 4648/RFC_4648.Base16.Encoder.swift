import ASCII
public import Binary_Endianness
public import Binary_Standard_Library_Integration

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
        return String(decoding: encoded.map(\.underlying), as: UTF8.self)
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
