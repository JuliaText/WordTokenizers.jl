# Regenerates `src/words/html_entities.jl` from the HTML_Entities.jl package.
#
# Usage (from the repository root):
#
#     julia gen/generate_html_entities.jl
#
# HTML_Entities.jl is installed into a temporary environment, so it does not
# become a dependency of WordTokenizers.

using Pkg
Pkg.activate(; temp = true, io = devnull)
Pkg.add(["HTML_Entities", "StrTables"]; io = devnull)

using HTML_Entities, StrTables

const OUTPUT = joinpath(@__DIR__, "..", "src", "words", "html_entities.jl")

let d = HTML_Entities.default,
    version = pkgversion(HTML_Entities)

    names = sort!(collect(String, d))
    open(OUTPUT, "w") do io
        println(io, "# HTML named character references (name without `&`/`;` => replacement text).")
        println(io, "# Generated from HTML_Entities.jl v$version (W3C HTML5 entity list); do not edit by hand.")
        println(io, "# Embedded as a constant so the tokenizers have no run-time table loading,")
        println(io, "# which keeps them compatible with `juliac --trim`.")
        println(io, "# To regenerate, run from the repository root: `julia gen/generate_html_entities.jl`")
        println(io, "const HTML_ENTITIES = Dict{String,String}(")
        for n in names
            println(io, "    ", repr(n), " => ", repr(lookupname(d, n)), ",")
        end
        println(io, ")")
    end
    println("Wrote $(length(names)) entities to $(normpath(OUTPUT))")
end
