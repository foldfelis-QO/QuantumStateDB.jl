abstract type QuantumStates end

struct SqueezedStates <: QuantumStates end
struct SqueezedThermalStates <: QuantumStates end

Base.string(::Type{SqueezedStates}) = "squeezed_states"
Base.string(::Type{SqueezedThermalStates}) = "squeezed_thermal_states"

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
