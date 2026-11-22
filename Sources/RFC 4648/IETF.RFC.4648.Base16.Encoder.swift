import ASCII
public import Binary

extension IETF.RFC.`4648`.Base16 {

    public struct Encoder: Sendable {
        @inlinable
        public init() {}
    }
}

extension IETF.RFC.`4648`.Base16.Encoder {

    @inlinable
    public func callAsFunction<Bytes: Swift::Collection>(
        _ bytes: Bytes,
        uppercase: Bool = false
    ) -> String where Bytes.Element == Byte {
        let encoded: [ASCII.Code] = IETF.RFC.`4648`.Base16.encode(bytes, uppercase: uppercase)
        return String(decoding: encoded.map({ $0.underlying }), as: UTF8.self)
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
