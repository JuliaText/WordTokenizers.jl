using Test
using WordTokenizers

@testset "Tweet Tokenize" begin
    @testset "Basic Tests" begin
        s0 = "This is a cooool #dummysmiley: :-) :-P <3 and some arrows < > -> <--"
        @test tweet_tokenize(s0) ==
            ["This", "is", "a", "cooool", "#dummysmiley", ":", ":-)", ":-P", "<3", "and", "some", "arrows", "<", ">", "->", "<--"]

        s1 = "@Joyster2012 @CathStaincliffe Good for you, girl!! Best wishes :-)"
        @test tweet_tokenize(s1) ==
            ["@Joyster2012", "@CathStaincliffe", "Good", "for", "you", ",", "girl", "!", "!", "Best", "wishes", ":-)"]

        s2 = "3Points for #DreamTeam Gooo BAILEY! :) #PBB737Gold @PBBabscbn"
        @test tweet_tokenize(s2) ==
            ["3Points", "for", "#DreamTeam", "Gooo", "BAILEY", "!", ":)", "#PBB737Gold", "@PBBabscbn"]

        s3 = "@Insanomania They do... Their mentality doesn't :("
        @test tweet_tokenize(s3) ==
            ["@Insanomania", "They", "do", "...", "Their", "mentality", "doesn't", ":("]

        s4 = "RT @facugambande: Ya por arrancar a grabar !!! #TirenTirenTiren vamoo !!"
        @test tweet_tokenize(s4) ==
            ["RT", "@facugambande", ":", "Ya", "por", "arrancar", "a", "grabar", "!", "!", "!", "#TirenTirenTiren", "vamoo", "!", "!"]

        s5 = "@crushinghes the summer holidays are great but I'm so bored already :("
        @test tweet_tokenize(s5, reduce_len=true) ==
            ["@crushinghes", "the", "summer", "holidays", "are", "great", "but", "I'm", "so", "bored", "already", ":("]

        s6 = "@jrmy: I'm REALLY HAPPYYY about that! NICEEEE :D :P"
        @test tweet_tokenize(s6) ==
            ["@jrmy", ":", "I'm", "REALLY", "HAPPYYY", "about", "that", "!", "NICEEEE", ":D", ":P"]
    end

    @testset "Remove Handles and Reduce Length" begin
        s7 = "@remy: This is waaaaayyyy too much for you!!!!!!"
        @test tweet_tokenize(s7, strip_handle=true, reduce_len=true) ==
            [":", "This", "is", "waaayyy", "too", "much", "for", "you", "!", "!", "!"]

        s8 = "@_willy65: No place for @chuck tonight. Sorry."
        @test tweet_tokenize(s8, strip_handle=true, reduce_len=true) ==
            [":", "No", "place", "for", "tonight", ".", "Sorry", "."]

        s9 = "@mar_tin is a great developer. Contact him at mar_tin@email.com."
        @test tweet_tokenize(s9, strip_handle=true, reduce_len=true) ==
            ["is", "a", "great", "developer", ".", "Contact", "him", "at", "mar_tin@email.com", "."]
       end

    @testset "Test long sentences" begin
        s10 = "Photo: Aujourd'hui sur http://t.co/0gebOFDUzn Projet... http://t.co/bKfIUbydz2.............................. http://fb.me/3b6uXpz0L"
        @test tweet_tokenize(s10) ==
            ["Photo", ":", "Aujourd'hui", "sur", "http://t.co/0gebOFDUzn", "Projet", "...", "http://t.co/bKfIUbydz2", "...", "http://fb.me/3b6uXpz0L"]
    end
end

@testset "Replace HTML Entities" begin
    @test tweet_tokenize("An HTML Entity - &Delta;") ==
        ["An", "HTML", "Entity", "-", "Δ"]

    @test tweet_tokenize("Another HTML Entity - &#916;") ==
        ["Another", "HTML", "Entity", "-", "Δ"]

    @test tweet_tokenize("Another HTML Entity - &#x394;") ==
        ["Another", "HTML", "Entity", "-", "Δ"]

    @test tweet_tokenize("Price: &pound;100") ==
        [ "Price", ":", "£", "100"]

    @test tweet_tokenize("Check out this invalid symbol &#x81;") ==
        [ "Check", "out", "this", "invalid", "symbol", "\u81"]

    @test tweet_tokenize("A&#x95;B = B&#x95;A ") ==
        [ "A", "•", "B", "=", "B", "•", "A"]

    @test tweet_tokenize("Check out this symbol in Windows-1252 encoding &#x80;") ==
        [ "Check", "out", "this", "symbol", "in", "Windows", "-", "1252", "encoding", "€"]
end
