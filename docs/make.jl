using LimitOfDetection
using Documenter

DocMeta.setdocmeta!(LimitOfDetection, :DocTestSetup, :(using LimitOfDetection); recursive=true)

makedocs(;
    modules=[LimitOfDetection],
    authors="Jonathan Bieler <jonathan.bieler@alumni.epfl.ch> and contributors",
    repo="https://github.com/jonathanBieler/LimitOfDetection.jl/blob/{commit}{path}#{line}",
    sitename="LimitOfDetection.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://jonathanBieler.github.io/LimitOfDetection.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/jonathanBieler/LimitOfDetection.jl",
    devbranch="main",
)
