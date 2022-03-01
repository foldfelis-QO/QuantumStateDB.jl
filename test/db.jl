@testset "db" begin
    # drop database "test_db" if exists
    drop_db(DBNAME)

    # create db
    create_database(DBNAME)
    @test DBNAME in from_sql("SELECT datname FROM pg_database;")[!, 1]

    # enable uuid utils in "test_db"
    @test enable_uuid(DBNAME) == 0

    # table type
    struct TestTable end
    Base.string(::Type{TestTable}) = "test_table"

    # modify dbconfig
    dbconfig = copy(current_dbconfig())
    dbconfig[:dbname] = DBNAME

    # create table including uuid column into "test_db"
    column_names = [
        "ID",
        "r", "theta",
        "DIM", "rho",
        "NPoints", "BHD",
    ]

    create_table(
        string(TestTable),
        """
        CREATE TABLE $(string(TestTable)) (
            $(column_names[1]) UUID DEFAULT uuid_generate_v4(),

            $(column_names[2]) FLOAT8 NOT NULL,
            $(column_names[3]) FLOAT8 NOT NULL,

            $(column_names[4]) INT8 NOT NULL,
            $(column_names[5]) BYTEA COMPRESSION lz4 NOT NULL,

            $(column_names[6]) INT8 NOT NULL,
            $(column_names[7]) BYTEA COMPRESSION lz4 NOT NULL,

            PRIMARY KEY ($(column_names[1]))
        );
        """,
        dbconfig=dbconfig
    )

    column_names_from_sql = from_sql(
        """
        SELECT column_name
            FROM information_schema.columns
            WHERE table_schema = 'public' AND table_name = '$(string(TestTable))';
        """,
        dbconfig=dbconfig
    )[!, 1]

    @test all(lowercase(col) in column_names_from_sql for col in column_names)

    # test insert
    r = 0.8; θ = π/2
    dim = 1000; ρ = SqueezedState(r, θ, Matrix, dim=dim)
    np = 40960; ps = rand(GaussianStateBHD(ρ), np)

    df = DataFrame([
        :r=>r, :theta=>θ,
        :DIM=>dim, :rho=>hexbytes_str(ρ),
        :NPoints=>np, :BHD=>hexbytes_str(ps)
    ])

    to_sql(df, TestTable, dbconfig=dbconfig)

    df_from_sql = from_sql(TestTable, dbconfig=dbconfig)

    df_from_sql[!, :r] = Float64.(df_from_sql[!, :r])
    df_from_sql[!, :theta] = Float64.(df_from_sql[!, :theta])
    df_from_sql[!, :dim] = Int.(df_from_sql[!, :dim])
    df_from_sql[!, :rho] = hexbytes2array(ComplexF64).(df_from_sql[!, :rho])
    df_from_sql[!, :npoints] = Int.(df_from_sql[!, :npoints])
    df_from_sql[!, :bhd] = hexbytes2array(Float64).(df_from_sql[!, :bhd])

    @test df_from_sql[1, :r] == r
    @test df_from_sql[1, :theta] == θ
    @test df_from_sql[1, :dim] == dim
    @test all(reshape(df_from_sql[1, :rho], dim, dim) .== ρ)
    @test df_from_sql[1, :npoints] == np
    @test all(reshape(df_from_sql[1, :bhd], 2, np) .== ps)
end

@testset "insert" begin
    dbconfig = copy(current_dbconfig())
    dbconfig[:dbname] = DBNAME

    n = 10

    r = LinRange(0, 1, n); θ = LinRange(0, 2π, n)
    dim = 100; sq(r, θ) = SqueezedState(r, θ, Matrix, dim=dim); ρ = sq.(r, θ)
    np = 4096; p(ρ) = rand(GaussianStateBHD(ρ), np); ps = p.(ρ)

    df = DataFrame([
        :r=>r, :theta=>θ,
        :DIM=>dim, :rho=>hexbytes_str.(ρ),
        :NPoints=>np, :BHD=>hexbytes_str.(ps)
    ])

    to_sql(df, TestTable, dbconfig=dbconfig)
end
