using Base.Test
using WordTokenizers

@testset "Orignal Penn" begin
    @test penn_tokenize("hello there mate") == ["hello", "there", "mate"]
    @test penn_tokenize("you shouldn't do that") == ["you", "should", "n't", "do", "that"]
    @test penn_tokenize("Dr. Rob is here") == ["Dr.", "Rob", "is", "here"]
    @test penn_tokenize("He (was) worried!") == ["He", "&", "was", "&", "worried", "&"]
    @test penn_tokenize("Today: work, sleep, eat") == ["Today", "&", "work", "&", "sleep", "&", "eat"]
end

@testset "Improved Penn" begin
    # Checked these against nltk.tokenize.TreebankWordTokenizer().tokenize
    # Don't check against nltk.word_tokenize as that runs sentenence tokenisation first.
    @test improved_penn_tokenize("hello there mate") == ["hello", "there", "mate"]
    @test improved_penn_tokenize("you shouldn't do that") == ["you", "should", "n't", "do", "that"]
    @test improved_penn_tokenize("He (was) worried!") == ["He", "(", "was", ")", "worried", "!"]
    @test improved_penn_tokenize("Dr. Rob is here") == ["Dr.", "Rob", "is", "here"]
    @test improved_penn_tokenize("Today: work, sleep, eat") == ["Today", ":", "work", ",", "sleep", ",", "eat"]
end
