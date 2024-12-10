using SATSolvers
using Documenter

DocMeta.setdocmeta!(SATSolvers, :DocTestSetup, :(using SATSolvers); recursive=true)

makedocs(;
    modules=[SATSolvers],
    authors="nzy1997",
    sitename="SATSolvers.jl",
    format=Documenter.HTML(;
        canonical="https://nzy1997.github.io/SATSolvers.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/nzy1997/SATSolvers.jl",
    devbranch="main",
)
