@testset "db" begin
    db_name = "test_db"
    create_database(db_name)
    @test db_name in from_sql("SELECT datname FROM pg_database;")[!, 1]
end
