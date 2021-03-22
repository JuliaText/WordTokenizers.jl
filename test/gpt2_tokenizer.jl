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
    @test tokenize(gpt2_tokenizer, "I love julia language") == ["I",
                                                           "Ġlove",
                                                           "Ġj",
                                                           "ulia",
                                                           "Ġlanguage"]
    tokens = tokenize(gpt2_tokenizer, "I love julia language")
    @test ids_from_tokens(gpt2_tokenizer, tokens) == [40, 1842, 474, 43640, 3303]
    @test sentence_from_tokens(gpt2_tokenizer, tokens) == "I love julia language"

    tokens= tokenize(gpt2_tokenizer, "A census taker once tried to test me. I ate his liver with some fava beans and a nice Chianti.")
    @test tokens  == ["A", "Ġcensus", "Ġt", "aker", "Ġonce",
                     "Ġtried", "Ġto", "Ġtest", "Ġme", ".",
                     "ĠI", "Ġate", "Ġhis", "Ġliver", "Ġwith",
                     "Ġsome", "Ġfav", "a","Ġbeans", "Ġand",
                     "Ġa", "Ġnice", "ĠCh", "iant", "i", "."]
    @test ids_from_tokens(gpt2_tokenizer, tokens) == [32, 21649, 256, 3110, 1752, 3088, 284, 1332, 502, 13, 314, 15063,
                                      465, 14383, 351, 617, 2090, 64, 16567, 290, 257, 3621, 609, 3014,
                                      72, 13]

   text = "Badges? We ain't got no badges:) We don't need no badges:p I don't have to show you any stinking badges!"
   tokens = tokenize(gpt2_tokenizer, text)
   @test tokens == ["Bad", "ges", "?", "ĠWe", "Ġain", "'t", "Ġgot", "Ġno", "Ġbadges", ":", ")", "ĠWe",
                    "Ġdon", "'t", "Ġneed", "Ġno", "Ġbadges", ":", "p", "ĠI", "Ġdon", "'t", "Ġhave",
                    "Ġto", "Ġshow", "Ġyou", "Ġany", "Ġst", "inking", "Ġbadges", "!"]
   @test sentence_from_tokens(gpt2_tokenizer, tokens) == text
end
