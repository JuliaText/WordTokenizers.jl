using WordTokenizers
using Test

files = ["simple",
         "sedbased",
         "sentence_splitting",
         "set_method_api",
	 "reversible_tok",
         "toktok"
        ]

@testset "$file" for file in files
    include(file * ".jl")
end
