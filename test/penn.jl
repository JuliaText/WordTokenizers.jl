using Base.Test
using WordTokenizers

@testset "Orignal Penn" begin
    @test penn_tokenize("hello there mate") == ["hello", "there", "mate"]
    @test penn_tokenize("you shouldn't do that") == ["you", "should", "n't", "do", "that"]
    @test penn_tokenize("Dr. Rob is here") == ["Dr.", "Rob", "is", "here"]
    @test penn_tokenize("He (was) worried!") == ["He", "&", "was", "&", "worried", "&"]
    @test penn_tokenize("Today: work, sleep, eat") == ["Today", "&", "work", "&", "sleep", "&", "eat"]
end

@testset "Punctuation Preserving Penn" begin
    # Checked these against nltk.tokenize.TreebankWordTokenizer().tokenize
    # Don't check against nltk.word_tokenize as that runs sentenence tokenisation first, and is slightly different.
    @test pp_penn_tokenize("hello there mate") == ["hello", "there", "mate"]
    @test pp_penn_tokenize("you shouldn't do that") == ["you", "should", "n't", "do", "that"]
    @test pp_penn_tokenize("He (was) worried!") == ["He", "(", "was", ")", "worried", "!"]
    @test pp_penn_tokenize("Dr. Rob is here") == ["Dr.", "Rob", "is", "here"]
    @test pp_penn_tokenize("Today: work, sleep, eat") == ["Today", ":", "work", ",", "sleep", ",", "eat"]
end
