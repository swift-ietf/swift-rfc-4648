// RFC_4648.Strictness.swift
// swift-rfc-4648
//
// Opt-in decoding strictness for the Base64/Base32 family (RFC 4648 §3.3).

extension RFC_4648 {
    /// Decoding strictness for the Base64 and Base32 family of decoders.
    ///
    /// RFC 4648 §3.3 permits implementations to ignore whitespace and does not
    /// mandate rejecting non-canonical padding bits, but a *validating*
    /// implementation (one used to check data came from a trusted encoder, or
    /// to prevent encoding-ambiguity attacks) needs the option to refuse both.
    /// This package's decoders default to ``lenient`` — the historical
    /// behavior every existing caller already depends on — and this type adds
    /// an explicit, opt-in ``strict`` posture rather than silently changing
    /// what already-shipped call sites accept.
    ///
    /// Remainder lengths that can never represent a whole number of bytes
    /// (1 sextet for Base64; 1, 3, or 6 quintets for Base32) are rejected
    /// unconditionally by the decoders regardless of this setting — those are
    /// not a laxity/strictness axis, they are simply not valid Base64/Base32.
    public struct Strictness: Sendable, Hashable {
        /// If `true`, any whitespace character (SP, HTAB, CR, LF) in the input
        /// is rejected instead of being skipped.
        public var rejectWhitespace: Bool

        /// If `true`, a short final group whose unused low bits (the bits that
        /// don't map onto a whole output byte) are nonzero is rejected. Per
        /// RFC 4648 §3.5, those bits SHOULD be zero; a nonzero value means the
        /// same byte sequence has more than one valid encoding.
        public var rejectNonzeroTrailingBits: Bool

        @inlinable
        public init(rejectWhitespace: Bool, rejectNonzeroTrailingBits: Bool) {
            self.rejectWhitespace = rejectWhitespace
            self.rejectNonzeroTrailingBits = rejectNonzeroTrailingBits
        }

        /// Historical default: whitespace is skipped, non-canonical trailing
        /// padding bits are accepted. Every decode entry point in this
        /// package defaults to this posture.
        public static let lenient = Strictness(rejectWhitespace: false, rejectNonzeroTrailingBits: false)

        /// A validating-implementation posture: whitespace and non-canonical
        /// padding bits are both rejected.
        public static let strict = Strictness(rejectWhitespace: true, rejectNonzeroTrailingBits: true)
    }
}
