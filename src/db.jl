export
    load_config!,
    current_dbconfig,

    create_database,
    enable_uuid,
    create_table,
    from_sql,
    to_sql

# #############
# # db config #
# #############

db_config_path() = joinpath(DEPOT_PATH[1], "config", "QuantumStateDB", "dbconfig.json")

const DBCONFIG = Dict{Symbol,Any}()

function load_config!(; auth_file::String=db_config_path())
    global DBCONFIG

    if isfile(auth_file)
        f = open(auth_file, "r")
        for (k, v) in JSON3.read(f)
            DBCONFIG[k] = v
        end
    else
        DBCONFIG[:user] = ENV["PGUSER"]
        DBCONFIG[:password] = ENV["PGPASSWORD"]
        DBCONFIG[:dbname] = ENV["PGDATABASE"]
    end

    return DBCONFIG
end

current_dbconfig() = DBCONFIG

to_config_string(config::Dict) = join(["$k=$v" for (k, v) in config], " ")

# #############
# # create db #
# #############

function create_database(dbname::String; dbconfig=current_dbconfig())
    connection = LibPQ.Connection(to_config_string(dbconfig))
        result = execute(connection, "CREATE DATABASE $(dbname);")
        close(result)
    close(connection)

    return dbname
end

function enable_uuid(dbname::String; dbconfig=current_dbconfig())
    dbconfig = copy(dbconfig)
    dbconfig[:dbname] = dbname
    connection = LibPQ.Connection(to_config_string(dbconfig))
        execute(connection, "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";")
    close(connection)

    return 0
end

# ################
# # create table #
# ################

function create_table(table_name::DataType, sql; dbconfig=current_dbconfig())
    connection = LibPQ.Connection(to_config_string(dbconfig))
        @info "Drop table $(string(table_name)) if exists!"
        execute(connection, "DROP TABLE IF EXISTS $(string(table_name));")

        result = execute(connection, sql)
        close(result)
    close(connection)

    return table_name
end

# ###############
# # query utils #
# ###############

function from_sql(table_name::DataType; dbconfig=current_dbconfig())
    connection = LibPQ.Connection(to_config_string(dbconfig))
        result = execute(connection, "SELECT * FROM $(string(table_name));")
            df = DataFrame(result)
        close(result)
    close(connection)

    return df
end

function from_sql(sql::String; dbconfig=current_dbconfig())
    connection = LibPQ.Connection(to_config_string(dbconfig))
        result = execute(connection, sql)
            df = DataFrame(result)
        close(result)
    close(connection)

    return df
end

function to_sql(df::DataFrame, table_name::DataType; dbconfig=current_dbconfig())
    col_names = join(lowercase.(names(df)), ", ")
    vals = join(["\$$i" for i in 1:ncol(df)], ", ")
    connection = LibPQ.Connection(to_config_string(dbconfig))
        execute(connection, "BEGIN;")
            LibPQ.load!(
                columntable(df),
                connection,
                "INSERT INTO $(string(table_name)) ($col_names) VALUES ($vals);",
            )
        execute(connection, "COMMIT;")
    close(connection)

    return 0
end
