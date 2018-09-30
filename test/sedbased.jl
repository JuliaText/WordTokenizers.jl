using Test
using WordTokenizers


@testset "Orignal Penn" begin
    @test penn_tokenize("hello there mate") == ["hello", "there", "mate"]
    @test penn_tokenize("you shouldn't do that") == ["you", "should", "n't", "do", "that"]
    @test penn_tokenize("Dr. Rob is here") == ["Dr.", "Rob", "is", "here"]
    @test penn_tokenize("He (was) worried!") == ["He", "(", "was", ")", "worried", "!"]
    @test penn_tokenize("Today: work, sleep, eat") == ["Today", ":", "work", ",", "sleep", ",", "eat"]
    @test penn_tokenize("I cannot tokenize") == ["I", "can", "not", "tokenize"]

    # Original does not sperate the second of  repreated "cannot"
    s4 = "I cannot cannot work under these conditions!"
    @test penn_tokenize(s4) ==
        ["I", "can", "not", "cannot", "work", "under", "these", "conditions", "!"]
end


@testset "Common $(word_tokenize)" for word_tokenize in [improved_penn_tokenize, nltk_word_tokenize]
    @testset "basic tests" begin
        @test word_tokenize("hello there mate") == ["hello", "there", "mate"]
        @test word_tokenize("you shouldn't do that") == ["you", "should", "n't", "do", "that"]
        @test word_tokenize("He (was) worried!") == ["He", "(", "was", ")", "worried", "!"]
        @test word_tokenize("Dr. Rob is here") == ["Dr.", "Rob", "is", "here"]
        @test word_tokenize("Today: work, sleep, eat") == ["Today", ":", "work", ",", "sleep", ",", "eat"]
    end

    @testset "NLTK's tests" begin
        # from https://github.com/nltk/nltk/blob/326f3ceb38eb103bec8158cbdc18d931a548f0ad/nltk/test/tokenize.doctest#L12-L41

        s1 = "On a \$50,000 mortgage of 30 years at 8 percent, the monthly payment would be \$366.88."
        @test word_tokenize(s1) ==
            ["On", "a", "\$", "50,000", "mortgage", "of", "30", "years", "at", "8", "percent", ",", "the", "monthly", "payment", "would", "be", "\$", "366.88", "."]

        s2 = "\"We beat some pretty good teams to get here,\" Slocum said."
        @test word_tokenize(s2) ==
            ["``", "We", "beat", "some", "pretty", "good", "teams", "to", "get", "here", ",", "''", "Slocum", "said", "."]

        s3 = "Well, we couldn't have this predictable, cliche-ridden, \"Touched by an Angel\" (a show creator John Masius worked on) wanna-be if she didn't."
        @test word_tokenize(s3) ==
            ["Well", ",", "we", "could", "n't", "have", "this", "predictable", ",", "cliche-ridden", ",", "``", "Touched", "by", "an", "Angel", "''", "(", "a", "show", "creator", "John", "Masius", "worked", "on", ")", "wanna-be", "if", "she", "did", "n't", "."]

        s4 = "I cannot cannot work under these conditions!"
        @test word_tokenize(s4) ==
            ["I", "can", "not", "can", "not", "work", "under", "these", "conditions", "!"]

        s5 = "The company spent \$30,000,000 last year."
        @test word_tokenize(s5) ==
            ["The", "company", "spent", "\$", "30,000,000", "last", "year", "."]

        s6 = "The company spent 40.75% of its income last year."
        @test word_tokenize(s6) ==
            ["The", "company", "spent", "40.75", "%", "of", "its", "income", "last", "year", "."]

        s7 = "He arrived at 3:00 pm."
        @test word_tokenize(s7) ==
            ["He", "arrived", "at", "3:00", "pm", "."]

        s8 = "I bought these items: books, pencils, and pens."
        @test word_tokenize(s8) ==
            ["I", "bought", "these", "items", ":", "books", ",", "pencils", ",", "and", "pens", "."]

        s9 = "Though there were 150, 100 of them were old."
        word_tokenize(s9) ==
            ["Though", "there", "were", "150", ",", "100", "of", "them", "were", "old", "."]

        s10 = "There were 300,000, but that wasn't enough."
        @test word_tokenize(s10) ==
            ["There", "were", "300,000", ",", "but", "that", "was", "n't", "enough", "."]
    end
end
