module QuantumStateDB

using JSON3
using LibPQ
using DataFrames

include("utils.jl")
include("db.jl")
include("table.jl")

end # module

#=
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

DROP TABLE IF EXISTS squeezed_state;
CREATE TABLE squeezed_state (
    ID UUID DEFAULT uuid_generate_v4(),

    r FLOAT8 NOT NULL,
    theta FLOAT8 NOT NULL,

    DIM INT8 NOT NULL,
    rho FLOAT8[][] NOT NULL,

    NPoints INT8 NOT NULL,
    BHD POINT[] NOT NULL,

    PRIMARY KEY (ID)
);

INSERT INTO squeezed_state (
    r, theta,
    DIM, rho,
    NPoints, BHD
) VALUES (
    0.8, 3.14159,
    5, '{
        {1.0, 2.0, 3.0, 4.0, 5.0},
        {1.0, 2.0, 3.0, 4.0, 5.0},
        {1.0, 2.0, 3.0, 4.0, 5.0},
        {1.0, 2.0, 3.0, 4.0, 5.0},
        {1.0, 2.0, 3.0, 4.0, 5.0}
    }',
    10, '{
        "(0.1, 0.0)", "(0.2, 0.0)", "(0.3, 0.0)", "(0.4, 0.0)", "(0.5, 0.0)",
        "(0.6, 0.0)", "(0.7, 0.0)", "(0.8, 0.0)", "(0.9, 0.0)", "(0.01, 0.0)"
    }'
);
=#
