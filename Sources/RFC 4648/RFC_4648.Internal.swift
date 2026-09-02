public import ASCII

extension RFC_4648 {

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

            let b1 = b1Byte.bitPattern
            let b2 = iterator.next()?.bitPattern
            let b3 = iterator.next()?.bitPattern

            buffer.append(table[Int((b1 >> 2) & 0x3F)])

            let c2 = ((b1 << 4) | ((b2 ?? 0) >> 4)) & 0x3F
            buffer.append(table[Int(c2)])

            guard let b2 else {
                if padding {
                    buffer.append(RFC_4648.padding)
                    buffer.append(RFC_4648.padding)
                }
                break
            }

            let c3 = ((b2 << 2) | ((b3 ?? 0) >> 6)) & 0x3F
            buffer.append(table[Int(c3)])

            guard let b3 else {
                if padding {
                    buffer.append(RFC_4648.padding)
                }
                break
            }

            buffer.append(table[Int(b3 & 0x3F)])
        }
    }

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

        func onlyTrailingWhitespaceRemains() -> Bool {
            while let code = iterator.next() {
                if strictness.rejectWhitespace || !code.isWhitespace { return false }
            }
            return true
        }

        while true {
            values.removeAll(keepingCapacity: true)
            var paddingCount = 0

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

                if paddingCount > 0 { return false }
                guard let value = decodeTable[Int(code.underlying)] else { return false }
                values.append(value)
            }

            let totalChars = values.count + paddingCount

            if totalChars == 0 { break }

            if requirePadding {

                if totalChars != 4 { return false }
            }

            if values.isEmpty { return false }

            guard values.count >= 2 else { return false }
            hasDecodedAny = true

            if strictness.rejectNonzeroTrailingBits {
                switch values.count {
                case 2 where (values[1] & 0x0F) != 0: return false
                case 3 where (values[2] & 0x03) != 0: return false
                default: break
                }
            }

            buffer.append(Byte(bitPattern: (values[0] << 2) | (values[1] >> 4)))

            if values.count >= 3 {

                buffer.append(Byte(bitPattern: (values[1] << 4) | (values[2] >> 2)))

                if values.count >= 4 {

                    buffer.append(Byte(bitPattern: (values[2] << 6) | values[3]))
                }
            }

            if values.count < 4 {

                return onlyTrailingWhitespaceRemains()
            }
        }

        return hasDecodedAny || true
    }
}

extension RFC_4648 {

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

            let b1 = b1Byte.bitPattern
            let b2 = iterator.next()?.bitPattern
            let b3 = iterator.next()?.bitPattern
            let b4 = iterator.next()?.bitPattern
            let b5 = iterator.next()?.bitPattern

            buffer.append(table[Int((b1 >> 3) & 0x1F)])

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

            buffer.append(table[Int((b2 >> 1) & 0x1F)])

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

            buffer.append(table[Int((b4 >> 2) & 0x1F)])

            let c7 = ((b4 << 3) | ((b5 ?? 0) >> 5)) & 0x1F
            buffer.append(table[Int(c7)])

            guard let b5 else {
                if padding {
                    buffer.append(RFC_4648.padding)
                }
                break
            }

            buffer.append(table[Int(b5 & 0x1F)])
        }
    }

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

        func onlyTrailingWhitespaceRemains() -> Bool {
            while let code = iterator.next() {
                if strictness.rejectWhitespace || !code.isWhitespace { return false }
            }
            return true
        }

        while true {
            values.removeAll(keepingCapacity: true)
            var paddingCount = 0

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

                if paddingCount > 0 { return false }
                guard let value = decodeTable[Int(code.underlying)] else { return false }
                values.append(value)
            }

            let totalChars = values.count + paddingCount

            if totalChars == 0 { break }

            if values.isEmpty { return false }

            guard
                values.count == 2 || values.count == 4 || values.count == 5
                    || values.count == 7 || values.count == 8
            else { return false }
            hasDecodedAny = true

            if strictness.rejectNonzeroTrailingBits {
                switch values.count {
                case 2 where (values[1] & 0x03) != 0: return false
                case 4 where (values[3] & 0x0F) != 0: return false
                case 5 where (values[4] & 0x01) != 0: return false
                case 7 where (values[6] & 0x07) != 0: return false
                default: break
                }
            }

            buffer.append(Byte(bitPattern: (values[0] << 3) | (values[1] >> 2)))

            if values.count >= 4 {

                buffer.append(
                    Byte(bitPattern: (values[1] << 6) | (values[2] << 1) | (values[3] >> 4))
                )
            }

            if values.count >= 5 {

                buffer.append(Byte(bitPattern: (values[3] << 4) | (values[4] >> 1)))
            }

            if values.count >= 7 {

                buffer.append(
                    Byte(bitPattern: (values[4] << 7) | (values[5] << 2) | (values[6] >> 3))
                )
            }

            if values.count >= 8 {

                buffer.append(Byte(bitPattern: (values[6] << 5) | values[7]))
            }

            if values.count < 8 {

                return onlyTrailingWhitespaceRemains()
            }
        }

        return hasDecodedAny || true
    }
}
