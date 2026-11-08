import ASCII
import Binary

extension RFC_4648.Base32 {
    public struct Wrapper<Wrapped> {
        public let wrapped: Wrapped

        @inlinable
        public init(_ wrapped: Wrapped) {
            self.wrapped = wrapped
        }
    }
}
