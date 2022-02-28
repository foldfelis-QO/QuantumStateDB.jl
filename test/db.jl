# One should drop database "test_db" manually before running the test

@testset "db" begin
    # create db
    db_name = "test_db"
    create_database(db_name)
    @test db_name in from_sql("SELECT datname FROM pg_database;")[!, 1]

    # enable uuid utils in "test_db"
    @test enable_uuid(db_name) == 0

    # table type
    struct TestTable end
    Base.string(::Type{TestTable}) = "test_table"

    # create table including uuid column into "test_db"
    dbconfig = copy(current_dbconfig())
    dbconfig[:dbname] = db_name

    column_names = [
        "ID",
        "r", "theta",
        "DIM", "rho",
        "NPoints", "BHD",
    ]

    create_table(
        TestTable,
        """
        CREATE TABLE $(string(TestTable)) (
            $(column_names[1]) UUID DEFAULT uuid_generate_v4(),

            $(column_names[2]) FLOAT8 NOT NULL,
            $(column_names[3]) FLOAT8 NOT NULL,

            $(column_names[4]) INT8 NOT NULL,
            $(column_names[5]) FLOAT8[][] NOT NULL,

            $(column_names[6]) INT8 NOT NULL,
            $(column_names[7]) POINT[] NOT NULL,

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
end
