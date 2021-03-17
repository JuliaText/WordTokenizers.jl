using WordTokenizers
using Test

tokenizer = load(GPT2)

@testset "Pretrained" begin
    @test typeof(tokenizer) == WordTokenizers.GPT2Tokenizer
    @test typeof(tokenizer.vocab) == Dict{String, Any}
    @test typeof(tokenizer.rank) == Dict{Pair{String,String}, Int}
    @test typeof(tokenizer.cache) == Dict{String, Tuple}
    @test typeof(WordTokenizers.pretrained) == Dict{DataType,Array{String,1}}
    @test length(WordTokenizers.pretrained[GPT2]) == 2
end

@testset "Tokenizer and helper function" begin
    @test tokenizer.vocab["Hi"] == 17250
    @test tokenize("I love julia language", tokenizer) == ["I",
                                                           "Ġlove",
                                                           "Ġj",
                                                           "ulia",
                                                           "Ġlanguage"]
    tokens = tokenize("I love julia language", tokenizer)
    @test ids_from_tokens(tokens, tokenizer) == [40, 1842, 474, 43640, 3303]
    @test sentence_from_tokens_gpt2(tokens) == "I love julia language"
end
