using Talkon
using Documenter

DocMeta.setdocmeta!(Talkon, :DocTestSetup, :(using Talkon); recursive=true)

makedocs(;
    modules=[Talkon],
    authors="TBD",
    repo="https://github.com/tsurkys/Talkon.jl/blob/{commit}{path}#{line}",
    sitename="Talkon.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://tsurkys.github.io/Talkon.jl",
        siteurl="https://github.com/tsurkys/Talkon.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/tsurkys/Talkon.jl",
)
