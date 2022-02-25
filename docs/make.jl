using QuantumStateDB
using Documenter

DocMeta.setdocmeta!(QuantumStateDB, :DocTestSetup, :(using QuantumStateDB); recursive=true)

makedocs(;
    modules=[QuantumStateDB],
    authors="JingYu Ning <foldfelis@gmail.com> and contributors",
    repo="https://github.com/foldfelis-QO/QuantumStateDB.jl/blob/{commit}{path}#{line}",
    sitename="QuantumStateDB.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://foldfelis-QO.github.io/QuantumStateDB.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/foldfelis-QO/QuantumStateDB.jl",
    devbranch="master",
)
