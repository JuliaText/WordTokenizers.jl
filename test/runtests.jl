using WordTokenizers
using Base.Test

# write your own tests here
files = ["simple"]

@testset "$file" for file in files
    include(file * ".jl")
end
