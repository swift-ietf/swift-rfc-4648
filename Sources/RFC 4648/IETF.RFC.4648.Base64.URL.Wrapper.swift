import ASCII
import Binary

extension IETF.RFC.`4648`.Base64.URL {
    public struct Wrapper<Wrapped> {
        public let wrapped: Wrapped

        @inlinable
        public init(_ wrapped: Wrapped) {
            self.wrapped = wrapped
        }
    }
}
