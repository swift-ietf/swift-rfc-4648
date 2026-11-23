public import ASCII
public import IETF_RFC
import Standard_Library_Extensions

extension IETF.RFC {
    public enum `4648` {}
}

extension IETF.RFC.`4648` {

    public static let padding: ASCII.Code = .equalsSign
}
