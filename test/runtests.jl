using WordTokenizers
using Base.Test

# write your own tests here
files = ["simple",
         "sedbased"
        ]

@testset "$file" for file in files
    include(file * ".jl")
end
