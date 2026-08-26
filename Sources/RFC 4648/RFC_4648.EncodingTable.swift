public import ASCII

extension RFC_4648 {

    public struct EncodingTable: Sendable {

        public let encode: [ASCII.Code]

        public let decode: [UInt8?]

        public init(encode: [ASCII.Code], decode: [UInt8?]) {
            self.encode = encode
            self.decode = decode
        }

        public init(encode: [ASCII.Code], caseInsensitive: Bool = false) {
            self.encode = encode
            var decodeTable = [UInt8?](repeating: nil, count: 256)
            for (index, char) in encode.enumerated() {
                let raw = char.underlying
                decodeTable[Int(raw)] = UInt8(index)

                if caseInsensitive {
                    if raw >= 0x41, raw <= 0x5A {
                        decodeTable[Int(raw + 32)] = UInt8(index)
                    } else if raw >= 0x61, raw <= 0x7A {
                        decodeTable[Int(raw - 32)] = UInt8(index)
                    }
                }
            }
            decode = decodeTable
        }
    }
}
