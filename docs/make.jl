using Documenter, VKcurve

DocMeta.setdocmeta!(VKcurve, :DocTestSetup, :(using VKcurve); recursive=true)

makedocs(;
    modules=[VKcurve],
    authors="Jean Michel <jean.michel@imj-prg.fr> and contributors",
    sitename="VKcurve.jl",
    format=Documenter.HTML(;
        canonical="https://jmichel7.github.io/VKcurve.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
    warnonly=:missing_docs,
)

deploydocs(;
    repo="github.com/jmichel7/VKcurve.jl",
    devbranch="main",
)
