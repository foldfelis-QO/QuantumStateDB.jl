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
        "FloatVal",
        "IntVal",
        "ByteVec",
    ]

    create_table(
        string(TestTable),
        """
        CREATE TABLE $(string(TestTable)) (
            $(column_names[1]) UUID DEFAULT uuid_generate_v4(),

            $(column_names[2]) FLOAT8 NOT NULL,
            $(column_names[3]) INT8 NOT NULL,
            $(column_names[4]) BYTEA COMPRESSION lz4 NOT NULL,

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
    f = rand(Float64)
    i = rand(Int64)
    dim = 100
    b = rand(ComplexF64, dim, dim)

    df = DataFrame([
        :floatval => f,
        :intval => i,
        :ByteVec => hexbytes_str(b)
    ])

    to_sql(df, TestTable, dbconfig=dbconfig)

    df_from_sql = from_sql(TestTable, dbconfig=dbconfig)

    @test Float64(df_from_sql[1, :floatval]) == f
    @test Int64(df_from_sql[1, :intval]) == i
    @test all(reshape(hexbytes2array(ComplexF64, df_from_sql[1, :bytevec]), dim, dim) .== b)
end

@testset "insert" begin
    dbconfig = copy(current_dbconfig())
    dbconfig[:dbname] = DBNAME

    n = 10

    f = rand(Float64, n)
    i = rand(Int64, n)
    dim = 100
    b = [rand(ComplexF64, dim, dim) for _ in 1:n]

    df = DataFrame([
        :floatval => f,
        :intval => i,
        :ByteVec => hexbytes_str.(b)
    ])

    to_sql(df, TestTable, dbconfig=dbconfig)

    df_from_sql = from_sql(TestTable, dbconfig=dbconfig)

    for nᵢ in 1:n
        # index from db should +1 because we already insert 1 row in previous testset
        @test Float64(df_from_sql[nᵢ+1, :floatval]) == f[nᵢ]
        @test Int64(df_from_sql[nᵢ+1, :intval]) == i[nᵢ]
        @test all(reshape(hexbytes2array(ComplexF64, df_from_sql[nᵢ+1, :bytevec]), dim, dim) .== b[nᵢ])
    end
end
