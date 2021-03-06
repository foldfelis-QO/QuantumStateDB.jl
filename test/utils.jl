@testset "utils" begin
    m = [
        1 2 3 4 5;
        6 7 8 9 10
    ]

    @test QuantumStateDB.hexbytes(m) ==
        "0100000000000000" * "0600000000000000" *
        "0200000000000000" * "0700000000000000" *
        "0300000000000000" * "0800000000000000" *
        "0400000000000000" * "0900000000000000" *
        "0500000000000000" * "0a00000000000000"

    @test QuantumStateDB.hexbytes_str(m) == "\\x" *
        "0100000000000000" * "0600000000000000" *
        "0200000000000000" * "0700000000000000" *
        "0300000000000000" * "0800000000000000" *
        "0400000000000000" * "0900000000000000" *
        "0500000000000000" * "0a00000000000000"

    @test reshape(QuantumStateDB.hexbytes2array(Int)(
        reinterpret(UInt8, reshape(m, :))
    ), 2, 5) == m
end
