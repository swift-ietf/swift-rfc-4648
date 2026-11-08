extension RFC_4648 {

    public struct Strictness: Sendable, Hashable {

        public var rejectWhitespace: Bool

        public var rejectNonzeroTrailingBits: Bool

        @inlinable
        public init(rejectWhitespace: Bool, rejectNonzeroTrailingBits: Bool) {
            self.rejectWhitespace = rejectWhitespace
            self.rejectNonzeroTrailingBits = rejectNonzeroTrailingBits
        }

        public static let lenient = Strictness(
            rejectWhitespace: false,
            rejectNonzeroTrailingBits: false
        )

        public static let strict = Strictness(
            rejectWhitespace: true,
            rejectNonzeroTrailingBits: true
        )
    }
}
