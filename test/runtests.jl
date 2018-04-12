using WordTokenizers
using Base.Test

files = ["simple",
         "sedbased",
         "sentence_splitting"
        ]

@testset "$file" for file in files
    include(file * ".jl")
end
