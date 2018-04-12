using Base.Test
using WordTokenizers

@testset "Words" begin
    @test split("A good day", Words) == ["A", "good", "day"]
    @test split("it cannot cannot be today", penn_tokenize) == ["it", "can", "not", "cannot", "be", "today"]
end

@testset "Sentences" begin
    @test split("Never going to give you up. Never going to let you down.", Sentences) ==
        ["Never going to give you up.", "Never going to let you down."]

    @test split.(split("Never going to give you up. Never going to let you down.", Sentences), Words) ==
        [["Never", "going", "to", "give", "you", "up", "."],
        ["Never", "going", "to", "let", "you", "down", "."]]

end
