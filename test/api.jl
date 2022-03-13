@testset "api" begin
    # drop database "quantum_states" if exists
    drop_db(string(QuantumStatesData))

    @test QuantumStateDB.QSDB == "quantum_states"

    create_all()

    @test string(QuantumStatesData) in from_sql("SELECT datname FROM pg_database;")[!, 1]

    # modify dbconfig
    dbconfig = copy(current_dbconfig())
    dbconfig[:dbname] = string(QuantumStatesData)

    column_names = [
        "id",
        "r", "theta",
        "dim", "rho",
        "n_points", "bhd",
        "w_range", "w",
    ]
    column_names_from_sql = from_sql(
        """
        SELECT column_name
            FROM information_schema.columns
            WHERE table_schema='public' AND table_name='$(string(SqueezedStatesData))';
        """,
        dbconfig=dbconfig
    )[!, 1]
    @test all(lowercase(col) in column_names_from_sql for col in column_names)

    column_names = [
        "id",
        "r", "theta", "nbar",
        "dim", "rho",
        "n_points", "bhd",
        "w_range", "w",
    ]
    column_names_from_sql = from_sql(
        """
        SELECT column_name
            FROM information_schema.columns
            WHERE table_schema='public' AND table_name='$(string(SqueezedThermalStatesData))';
        """,
        dbconfig=dbconfig
    )[!, 1]
    @test all(lowercase(col) in column_names_from_sql for col in column_names)
end

@testset "insert into SqueezedStatesData" begin
    r = 0.8; θ = π/2
    dim = 100; ρ = SqueezedState(r, θ, Matrix, dim=dim)
    np = 40960; ps = rand(GaussianStateBHD(ρ), np)
    w_range = 3; w = wigner(ρ, LinRange(-w_range, w_range, 101), LinRange(-w_range, w_range, 101))

    df = DataFrame([
        :r=>r, :theta=>θ,
        :dim=>dim, :rho=>hexbytes_str(ρ),
        :n_points=>np, :bhd=>hexbytes_str(ps),
        :w_range=> w_range, :w=>hexbytes_str(w.𝐰_surface),
    ])

    # modify dbconfig
    dbconfig = copy(current_dbconfig())
    dbconfig[:dbname] = string(QuantumStatesData)

    to_sql(df, SqueezedStatesData, dbconfig=dbconfig)

    df_from_sql = from_sql(SqueezedStatesData, dbconfig=dbconfig)

    postprocessor = [
        :r => Float64,
        :theta => Float64,
        :dim => Int,
        :rho => hexbytes2array(ComplexF64),
        :n_points => Int,
        :bhd => hexbytes2array(Float64),
        :w_range => Int,
        :w => hexbytes2array(Float64),
    ]
    apply!(df_from_sql, postprocessor...)

    @test df_from_sql[1, :r] == r
    @test df_from_sql[1, :theta] == θ
    @test df_from_sql[1, :dim] == dim
    @test all(reshape(df_from_sql[1, :rho], dim, dim) .== ρ)
    @test df_from_sql[1, :n_points] == np
    @test all(reshape(df_from_sql[1, :bhd], 2, np) .== ps)
    @test df_from_sql[1, :w_range] == w_range
    @test all(reshape(df_from_sql[1, :w], 101, 101) .== w.𝐰_surface)
end

@testset "insert into SqueezedThermalStatesData" begin
    r = 0.8; θ = π/2; n̄ = 0.3
    dim = 100; ρ = SqueezedThermalState(r, θ, n̄, dim=dim)
    np = 40960; ps = rand(GaussianStateBHD(ρ), np)
    w_range = 3; w = wigner(ρ, LinRange(-w_range, w_range, 101), LinRange(-w_range, w_range, 101))

    df = DataFrame([
        :r=>r, :theta=>θ, :nbar=>n̄,
        :dim=>dim, :rho=>hexbytes_str(ρ),
        :n_points=>np, :bhd=>hexbytes_str(ps),
        :w_range=> w_range, :w=>hexbytes_str(w.𝐰_surface),
    ])

    # modify dbconfig
    dbconfig = copy(current_dbconfig())
    dbconfig[:dbname] = string(QuantumStatesData)

    to_sql(df, SqueezedThermalStatesData, dbconfig=dbconfig)

    df_from_sql = from_sql(SqueezedThermalStatesData, dbconfig=dbconfig)

    postprocessor = [
        :r => Float64,
        :theta => Float64,
        :nbar => Float64,
        :dim => Int,
        :rho => hexbytes2array(ComplexF64),
        :n_points => Int,
        :bhd => hexbytes2array(Float64),
        :w_range => Int,
        :w => hexbytes2array(Float64),
    ]
    apply!(df_from_sql, postprocessor...)

    @test df_from_sql[1, :r] == r
    @test df_from_sql[1, :theta] == θ
    @test df_from_sql[1, :nbar] == n̄
    @test df_from_sql[1, :dim] == dim
    @test all(reshape(df_from_sql[1, :rho], dim, dim) .== ρ)
    @test df_from_sql[1, :n_points] == np
    @test all(reshape(df_from_sql[1, :bhd], 2, np) .== ps)
    @test df_from_sql[1, :w_range] == w_range
    @test all(reshape(df_from_sql[1, :w], 101, 101) .== w.𝐰_surface)
end

@testset "insert table into SqueezedStatesData" begin
    # modify dbconfig
    dbconfig = copy(current_dbconfig())
    dbconfig[:dbname] = string(QuantumStatesData)

    n = 10

    r = LinRange(0, 1, n); θ = LinRange(0, 2π, n)
    dim = 100; sq(r, θ) = SqueezedState(r, θ, Matrix, dim=dim); ρ = sq.(r, θ)
    np = 4096; p(ρ) = rand(GaussianStateBHD(ρ), np); ps = p.(ρ)
    w_range = 3; wf = ρ->wigner(ρ, LinRange(-w_range, w_range, 101), LinRange(-w_range, w_range, 101)).𝐰_surface ; w = wf.(ρ)


    df = DataFrame([
        :r=>r, :theta=>θ,
        :dim=>repeat([dim], n), :rho=>hexbytes_str.(ρ),
        :n_points=>repeat([np], n), :bhd=>hexbytes_str.(ps),
        :w_range=> repeat([w_range], n), :w=>hexbytes_str.(w),
    ])

    to_sql(df, SqueezedStatesData, dbconfig=dbconfig)

    df_from_sql = from_sql(SqueezedStatesData, dbconfig=dbconfig)

    postprocessor = [
        :r => Float64,
        :theta => Float64,
        :dim => Int,
        :rho => hexbytes2array(ComplexF64),
        :n_points => Int,
        :bhd => hexbytes2array(Float64),
        :w_range => Int,
        :w => hexbytes2array(Float64),
    ]
    apply!(df_from_sql, postprocessor...)

    for nᵢ in 1:n
        # index from db should +1 because we already insert 1 row in previous testset
        @test df_from_sql[nᵢ+1, :r] == r[nᵢ]
        @test df_from_sql[nᵢ+1, :theta] == θ[nᵢ]
        @test df_from_sql[nᵢ+1, :dim] == dim
        @test all(reshape(df_from_sql[nᵢ+1, :rho], dim, dim) .== ρ[nᵢ])
        @test df_from_sql[nᵢ+1, :n_points] == np
        @test all(reshape(df_from_sql[nᵢ+1, :bhd], 2, np) .== ps[nᵢ])
        @test df_from_sql[nᵢ+1, :w_range] == w_range
        @test all(reshape(df_from_sql[nᵢ+1, :w], 101, 101) .== w[nᵢ])
    end
end

@testset "insert table into SqueezedThermalStatesData" begin
    # modify dbconfig
    dbconfig = copy(current_dbconfig())
    dbconfig[:dbname] = string(QuantumStatesData)

    n = 10

    r = LinRange(0, 1, n); θ = LinRange(0, 2π, n); n̄ = LinRange(0, 0.3, n)
    dim = 100; sqth(r, θ, n̄) = SqueezedThermalState(r, θ, n̄, dim=dim); ρ = sqth.(r, θ, n̄)
    np = 4096; p(ρ) = rand(GaussianStateBHD(ρ), np); ps = p.(ρ)
    w_range = 3; wf = ρ->wigner(ρ, LinRange(-w_range, w_range, 101), LinRange(-w_range, w_range, 101)).𝐰_surface ; w = wf.(ρ)


    df = DataFrame([
        :r=>r, :theta=>θ, :nbar=>n̄,
        :dim=>repeat([dim], n), :rho=>hexbytes_str.(ρ),
        :n_points=>repeat([np], n), :bhd=>hexbytes_str.(ps),
        :w_range=> repeat([w_range], n), :w=>hexbytes_str.(w),
    ])

    to_sql(df, SqueezedThermalStatesData, dbconfig=dbconfig)

    df_from_sql = from_sql(SqueezedThermalStatesData, dbconfig=dbconfig)

    postprocessor = [
        :r => Float64,
        :theta => Float64,
        :nbar => Float64,
        :dim => Int,
        :rho => hexbytes2array(ComplexF64),
        :n_points => Int,
        :bhd => hexbytes2array(Float64),
        :w_range => Int,
        :w => hexbytes2array(Float64),
    ]
    apply!(df_from_sql, postprocessor...)

    for nᵢ in 1:n
        # index from db should +1 because we already insert 1 row in previous testset
        @test df_from_sql[nᵢ+1, :r] == r[nᵢ]
        @test df_from_sql[nᵢ+1, :theta] == θ[nᵢ]
        @test df_from_sql[nᵢ+1, :nbar] == n̄[nᵢ]
        @test df_from_sql[nᵢ+1, :dim] == dim
        @test all(reshape(df_from_sql[nᵢ+1, :rho], dim, dim) .== ρ[nᵢ])
        @test df_from_sql[nᵢ+1, :n_points] == np
        @test all(reshape(df_from_sql[nᵢ+1, :bhd], 2, np) .== ps[nᵢ])
        @test df_from_sql[nᵢ+1, :w_range] == w_range
        @test all(reshape(df_from_sql[nᵢ+1, :w], 101, 101) .== w[nᵢ])
    end
end
