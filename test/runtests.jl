using WordTokenizers
using Base.Test

# write your own tests here
files = ["simple",
         "sedbased",
         "sentence_splitting"
        ]

@testset "$file" for file in files
    include(file * ".jl")
end
