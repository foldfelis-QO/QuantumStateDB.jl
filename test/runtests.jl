using QuantumStateDB
using Test

load_config!()
const PG = current_dbconfig()
@show PG[:user], PG[:password], PG[:dbname]

@testset "QuantumStateDB.jl" begin
    include("db.jl")
end
