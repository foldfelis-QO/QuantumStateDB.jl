export
    create_database,
    create_table,
    create_all,

    from_sql,
    apply!

# ######
# # db #
# ######

const QSDB = string(QuantumStatesData)

function create_database(; dbname::String=QSDB)
    create_database(dbname)
    enable_uuid(dbname)
end

function create_table(table::Type{<:QuantumStatesData}; dbname::String=QSDB)
    dbconfig = copy(current_dbconfig())
    dbconfig[:dbname] = dbname

    sql = gen_table_schema(table)

    return create_table(string(table), sql, dbconfig=dbconfig)
end

function create_all(; dbname::String=QSDB)
    create_database(dbname=dbname)

    for qs in subtypes(QuantumStatesData)
        create_table(qs, dbname=dbname)
    end
end

# ##############
# # preprocess #
# ##############

# ###############
# # postprocess #
# ###############

function nrow(table::Type{<:QuantumStatesData}; dbname::String=QSDB)
    dbconfig = copy(current_dbconfig())
    dbconfig[:dbname] = dbname

    df = from_sql("select count(*) from $(string(table));", dbconfig=dbconfig)

    return Int(df[1, 1])
end

function from_sql(
    table::Type{<:QuantumStatesData},
    n::Integer;
    offset=-1,
    order=:id,
    dbname::String=QSDB
)
    dbconfig = copy(current_dbconfig())
    dbconfig[:dbname] = dbname

    (offset < 0) && (offset = rand(0:nrow(table)-n))

    sql = """
        SELECT *
            FROM $(string(table))
            ORDER BY $order
        LIMIT $n OFFSET $offset;
    """

    return from_sql(sql, dbconfig=dbconfig)
end

function apply!(df, pairs...)
    for (col, f) in pairs
        df[!, col] = f.(df[!, col])
    end

    return df
end
