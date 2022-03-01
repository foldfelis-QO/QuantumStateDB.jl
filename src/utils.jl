export
    hexbytes,
    hexbytes_str,
    hexbytes2array

hexbytes(m::AbstractArray) = bytes2hex(reinterpret(UInt8, m))

hexbytes_str(m) = "\\x" * hexbytes(m)

hexbytes2array(T::Type{<:Number}, b::AbstractArray{UInt8}) = reinterpret(T, b)

hexbytes2array(T) = b -> hexbytes2array(T, b)
