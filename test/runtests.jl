using WordTokenizers
using Test

files = ["simple",
         "sedbased",
         "sentence_splitting",
         "set_method_api",
         "tweet_tokenize",
         "reversible_tok",
         "toktok",
         "gpt2_tokenizer",
         "sp_unigram"
        ]

@testset "$file" for file in files
    include(file * ".jl")
end
