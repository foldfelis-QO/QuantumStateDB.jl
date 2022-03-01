hexbytes(m::AbstractArray) = bytes2hex(reinterpret(UInt8, m))

hexbytes_str(m) = "\\x" * hexbytes(m)
