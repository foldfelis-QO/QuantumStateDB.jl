export
    QuantumStatesData,
    SqueezedStatesData,
    SqueezedThermalStatesData,

    gen_table_schema


abstract type QuantumStatesData end
struct SqueezedStatesData <: QuantumStatesData end
struct SqueezedThermalStatesData <: QuantumStatesData end

Base.string(::Type{QuantumStatesData}) = "quantum_states"
Base.string(::Type{SqueezedStatesData}) = "squeezed_states"
Base.string(::Type{SqueezedThermalStatesData}) = "squeezed_thermal_states"

function gen_table_schema(table::Type{SqueezedStatesData})
    return """
        CREATE TABLE $(string(table)) (
            ID UUID DEFAULT uuid_generate_v4(),

            r FLOAT8 NOT NULL,
            theta FLOAT8 NOT NULL,

            DIM INT8 NOT NULL,
            rho BYTEA COMPRESSION lz4 NOT NULL,

            NPoints INT8 NOT NULL,
            BHD BYTEA COMPRESSION lz4 NOT NULL,

            PRIMARY KEY (ID)
        );
    """
end

function gen_table_schema(table::Type{SqueezedThermalStatesData})
    return """
        CREATE TABLE $(string(table)) (
            ID UUID DEFAULT uuid_generate_v4(),

            r FLOAT8 NOT NULL,
            theta FLOAT8 NOT NULL,
            nbar FLOAT8 NOT NULL,

            DIM INT8 NOT NULL,
            rho BYTEA COMPRESSION lz4 NOT NULL,

            NPoints INT8 NOT NULL,
            BHD BYTEA COMPRESSION lz4 NOT NULL,

            PRIMARY KEY (ID)
        );
    """
end
