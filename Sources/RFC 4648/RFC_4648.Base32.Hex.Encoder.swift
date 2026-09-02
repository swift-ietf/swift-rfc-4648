import ASCII
public import Binary_Endianness
public import Binary_Standard_Library_Integration

extension RFC_4648.Base32.Hex {

    public struct Encoder: Sendable {
        @inlinable
        public init() {}
    }
}

extension RFC_4648.Base32.Hex.Encoder {

    @inlinable
    public func callAsFunction<Bytes: Collection>(
        _ bytes: Bytes,
        padding: Bool = true
    ) -> String where Bytes.Element == Byte {
        let codes: [ASCII.Code] = RFC_4648.Base32.Hex.encode(bytes, padding: padding)
        return String(decoding: codes.map(\.underlying), as: UTF8.self)
    }

    @inlinable
    public func callAsFunction<T: FixedWidthInteger>(
        _ value: T,
        padding: Bool = true
    ) -> String {
        callAsFunction(value.bytes(endianness: .big), padding: padding)
    }
}
