export
    SqueezedStatesData,
    SqueezedThermalStatesData,

    gen_table_schema


abstract type QuantumStatesData end

struct SqueezedStatesData <: QuantumStatesData end
struct SqueezedThermalStatesData <: QuantumStatesData end

Base.string(::Type{SqueezedStatesData}) = "squeezed_states"
Base.string(::Type{SqueezedThermalStatesData}) = "squeezed_thermal_states"

ρ2psql(m::AbstractMatrix) = "'" * replace(string([m[i, :] for i in 1:size(m, 1)]), '['=>'{', ']'=>'}') * "'"

function p2psql(p::AbstractMatrix)
    θs, xs = p[1, :], p[2, :]

    return replace(
        string(collect(zip(θs, xs))),
        "[" => "'{",
        "]" => "}'",
        "(" => "\"(",
        ")" => ")\""
    )
end

function gen_table_schema(table::Type{SqueezedStatesData})
    return """
        CREATE TABLE $(string(table)) (
            ID UUID DEFAULT uuid_generate_v4(),

            r FLOAT8 NOT NULL,
            theta FLOAT8 NOT NULL,

            DIM INT8 NOT NULL,
            rho FLOAT8[][] NOT NULL,

            NPoints INT8 NOT NULL,
            BHD POINT[] NOT NULL,

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
            rho FLOAT8[][] NOT NULL,

            NPoints INT8 NOT NULL,
            BHD POINT[] NOT NULL,

            PRIMARY KEY (ID)
        );
    """
end
