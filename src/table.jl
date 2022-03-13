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
            id UUID DEFAULT uuid_generate_v4(),

            r FLOAT8 NOT NULL,
            theta FLOAT8 NOT NULL,

            dim INT8 NOT NULL,
            rho BYTEA,

            n_points INT8 NOT NULL,
            bhd BYTEA,

            w_range INT8 NOT NULL,
            w BYTEA,

            PRIMARY KEY (ID)
        );
    """
end

function gen_table_schema(table::Type{SqueezedThermalStatesData})
    return """
        CREATE TABLE $(string(table)) (
            id UUID DEFAULT uuid_generate_v4(),

            r FLOAT8 NOT NULL,
            theta FLOAT8 NOT NULL,
            nbar FLOAT8 NOT NULL,

            dim INT8 NOT NULL,
            rho BYTEA,

            n_points INT8 NOT NULL,
            bhd BYTEA,

            w_range INT8 NOT NULL,
            w BYTEA,

            PRIMARY KEY (ID)
        );
    """
end
