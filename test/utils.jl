@testset "utils" begin
    m = [
        1 2 3 4 5;
        6 7 8 9 10
    ]

    @test QuantumStateDB.ρ2psql(m) == "'{{1, 2, 3, 4, 5}, {6, 7, 8, 9, 10}}'"

    @test QuantumStateDB.p2psql(m) == "'{\"(1, 6)\", \"(2, 7)\", \"(3, 8)\", \"(4, 9)\", \"(5, 10)\"}'"
end
