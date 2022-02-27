abstract type QuantumStates end

struct SqueezedStates <: QuantumStates end
struct SqueezedThermalStates <: QuantumStates end

Base.string(::Type{SqueezedStates}) = "squeezed_states"
Base.string(::Type{SqueezedThermalStates}) = "squeezed_thermal_states"

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

function generate_create_table(::Type{SqueezedStates})
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
    );"""
end
