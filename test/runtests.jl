using WordTokenizers
using Test

files = ["simple",
         "sedbased",
         "sentence_splitting",
         "set_method_api"
        ]

@testset "$file" for file in files
    include(file * ".jl")
end
