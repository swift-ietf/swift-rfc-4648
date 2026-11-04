# swift-rfc-4648

Use this package when you need to turn bytes or integers into Base64, Base64url, Base32, Base32hex or hexadecimal text, or read such text back. Start from `RFC_4648.Base64`, `RFC_4648.Base64.URL`, `RFC_4648.Base32`, `RFC_4648.Base32.Hex` or `RFC_4648.Base16`. The `RFC 4648 Foundation` product adds the same encodings to `Data`.

## Laws

- Base64, Base32 and Base32hex output is padded by default. Base64url output is not.
- Base32, Base32hex and hexadecimal decoding is case-insensitive. Base32 and Base32hex encode in uppercase, and hexadecimal encodes in lowercase unless asked for uppercase.
- Decoding is lenient by default: spaces, tabs and line breaks anywhere in the input are skipped, and nonzero unused bits in the last character are ignored. `RFC_4648.Strictness.strict` refuses both. Hexadecimal decoding always skips whitespace.
- Base64 decoding requires padding, so `Zg` is refused where `Zg==` decodes. Base64url and Base32 decoding accept input with or without padding.
- Only whitespace may follow padding or a short final group. `Zg==Zm8=` is refused rather than cut short. A final group too short to make a whole byte, such as one Base64 character or three Base32 characters, is refused.
- Hexadecimal input may start with `0x` or `0X`. An odd number of digits is refused, and so is a leading # sign.
- Text with any character outside ASCII never decodes. Empty text decodes to no bytes.
- `RFC_4648.Base64.isValid(_:)` and its siblings are true exactly when the default decode succeeds.
- An integer encodes as its big-endian bytes at its full width, in two's complement when signed. `String.hex` adds a `0x` prefix by default and keeps leading zeros, so `UInt16(255)` gives `0x00ff`.
- Decoding Base64, Base64url, Base32 or Base32hex text to an integer, as with `FixedWidthInteger.init(base64Encoded:)`, succeeds only when the decoded bytes exactly fill the integer's width. Fewer or more bytes, including none, give nil.
- Base32hex output sorts in the same order as the bytes it encodes.
- Base64 output never contains line breaks and matches Foundation's for the same bytes.
