import ASCII
public import Binary


extension RFC_4648.Base32.Hex {
    public struct Wrapper<Wrapped> {
        public let wrapped: Wrapped

        @inlinable
        public init(_ wrapped: Wrapped) {
            self.wrapped = wrapped
        }
    }
}
