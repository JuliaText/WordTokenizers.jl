using WordTokenizers
using Test

spm = load(Albert_Version1,"albert_base_v1_30k-clean.vocab")
@testset "Pretrained" begin
    @test typeof(spm) == WordTokenizers.Sentencepiecemodel
    @test typeof(spm.vocab) == Array{String,1}
    @test typeof(spm.logprob) == Array{Float64,1}
    @test typeof(pretrained) == Dict{DataType,Array{String,1}}
    @test length(pretrained[Albert_Version1]) == 4
end
@testset "forward and backword Passes" begin
    node = WordTokenizers.decode_forward(spm, "_I_love_julia_language")
    @test length(node) == 22
    @test length(WordTokenizers.decode_backward(spm, node)) == 5
end
@testset "tokinser and helper function" begin
    @test WordTokenizers.getindex(spm,"now") == 1388
    @test tokenizer(spm, "I love julia language") == ["_",        
                                                      "I",        
                                                      "_love",    
                                                      "_julia",   
                                                      "_language"]
    tks = tokenizer(spm, "i love julia language")
    @test ids_from_tokens(spm, tks) == [32, 340, 5424, 817]
    @test sentence_from_tokens(tks) == "i love julia language"
end
