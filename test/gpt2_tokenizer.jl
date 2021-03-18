using WordTokenizers
using Test

gpt2_tokenizer = load(GPT2)

@testset "Pretrained" begin
    @test typeof(gpt2_tokenizer) == WordTokenizers.GPT2Tokenizer
    @test typeof(gpt2_tokenizer.vocab) == Dict{String, Any}
    @test typeof(gpt2_tokenizer.rank) == Dict{Pair{String,String}, Int}
    @test typeof(gpt2_tokenizer.cache) == Dict{String, Tuple}
    @test typeof(WordTokenizers.pretrained) == Dict{DataType,Array{String,1}}
    @test length(WordTokenizers.pretrained[GPT2]) == 2
end

@testset "Tokenizer and helper function" begin
    @test gpt2_tokenizer.vocab["Hi"] == 17250
    @test tokenize("I love julia language", gpt2_tokenizer) == ["I",
                                                           "Ġlove",
                                                           "Ġj",
                                                           "ulia",
                                                           "Ġlanguage"]
    tokens = tokenize("I love julia language", gpt2_tokenizer)
    @test ids_from_tokens(tokens, gpt2_tokenizer) == [40, 1842, 474, 43640, 3303]
    @test sentence_from_tokens_gpt2(tokens) == "I love julia language"
end
