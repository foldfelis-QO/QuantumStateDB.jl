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
