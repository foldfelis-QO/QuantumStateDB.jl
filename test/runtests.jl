using QuantumStateDB
using LibPQ
using QuantumStateBase
using QuantumStateDistributions
using DataFrames
using Test

load_config!()
const PG = current_dbconfig()
@show PG[:user], PG[:password], PG[:dbname]

function drop_db(dbname::String)
    connection = LibPQ.Connection(QuantumStateDB.to_config_string(PG))
        @info "Drop database $dbname if exists!"
        execute(connection, "DROP DATABASE IF EXISTS $dbname;")
    close(connection)

    return 0
end

const DBNAME = "test_db"

@testset "QuantumStateDB.jl" begin
    include("utils.jl")
    include("db.jl")
    include("table.jl")
    include("api.jl")
end
