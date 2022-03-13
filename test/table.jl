@testset "table" begin
    # drop database "test_db" if exists
    drop_db(DBNAME)

    # create db
    create_database(DBNAME)
    @test DBNAME in from_sql("SELECT datname FROM pg_database;")[!, 1]

    # enable uuid utils in "test_db"
    @test enable_uuid(DBNAME) == 0

    # modify dbconfig
    dbconfig = copy(current_dbconfig())
    dbconfig[:dbname] = DBNAME

    # create "SqueezedStatesData" table including uuid column into "test_db"
    create_table(string(SqueezedStatesData), gen_table_schema(SqueezedStatesData), dbconfig=dbconfig)

    column_names = [
        "ID",
        "r", "theta",
        "DIM", "rho",
        "NPoints", "BHD",
        "WRange", "W",
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

    # create "SqueezedThermalStatesData" table including uuid column into "test_db"
    create_table(string(SqueezedThermalStatesData), gen_table_schema(SqueezedThermalStatesData), dbconfig=dbconfig)

    column_names = [
        "ID",
        "r", "theta", "nbar",
        "DIM", "rho",
        "NPoints", "BHD",
        "WRange", "W",
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
