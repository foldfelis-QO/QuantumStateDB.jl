export
    create_database,
    create_table,
    create_all

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
