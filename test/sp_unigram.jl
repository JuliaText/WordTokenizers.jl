using WordTokenizers
using Test

spm = load(ALBERT_V1)
@testset "Pretrained" begin
    @test typeof(spm) == WordTokenizers.SentencePieceModel
    @test typeof(spm.vocab_map) == Dict{String, Tuple{Float64, Int}}
    @test typeof(spm.unk_id) == Int
    @test typeof(WordTokenizers.pretrained) == Dict{DataType,Array{String,1}}
    @test length(WordTokenizers.pretrained[ALBERT_V1]) == 4
end
@testset "Forward and Backward passes" begin
    node = WordTokenizers.decode_forward(spm, "I love julia language")
    @test length(node) == 21
    @test length(WordTokenizers.decode_backward(spm, node, "i love julia language")) == 8
end
@testset "Tokenizers and helper function" begin
    @test spm.vocab_map["now"][2] == 1388
    @test tokenizer(spm, "I love julia language") == ["▁",        
                                                      "I",        
                                                      "▁love",    
                                                      "▁julia",   
                                                      "▁language"]
    tks = tokenizer(spm, "i love julia language")
    @test ids_from_tokens(spm, tks) == [32, 340, 5424, 817]
    @test sentence_from_tokens(tks) == "i love julia language"
end
