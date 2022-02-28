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
        "ID",
        "r", "theta",
        "DIM", "rho",
        "NPoints", "BHD",
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
        "ID",
        "r", "theta", "nbar",
        "DIM", "rho",
        "NPoints", "BHD",
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
