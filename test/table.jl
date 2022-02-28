@testset "table" begin
    column_names = [
        "ID",
        "r", "theta",
        "DIM", "rho",
        "NPoints", "BHD",
    ]

    # drop database "test_db" if exists
    drop_db(DBNAME)

    # create db
    create_database(DBNAME)
    @test DBNAME in from_sql("SELECT datname FROM pg_database;")[!, 1]

    # enable uuid utils in "test_db"
    @test enable_uuid(DBNAME) == 0

    # create table including uuid column into "test_db"
    dbconfig = copy(current_dbconfig())
    dbconfig[:dbname] = DBNAME

    create_table(SqueezedStatesData, gen_table_schema(SqueezedStatesData), dbconfig=dbconfig)

    column_names_from_sql = from_sql(
        """
        SELECT column_name
            FROM information_schema.columns
            WHERE table_schema='public' AND table_name='$(string(SqueezedStatesData))';
        """,
        dbconfig=dbconfig
    )[!, 1]

    @test all(lowercase(col) in column_names_from_sql for col in column_names)
end
