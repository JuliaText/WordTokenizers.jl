using Test
using WordTokenizers

@testset "Tweet Tokenize" begin
    @test "Basic Tests" begin

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
    end

    @test "Remove Handles and Reduce Length" begin
        s6 = "@remy: This is waaaaayyyy too much for you!!!!!!"
        @test tweet_tokenize(s6, strip_handles=true, reduce_len=true) ==
            [":", "This", "is", "waaayyy", "too", "much", "for", "you", "!", "!", "!"]

        s7 = "@_willy65: No place for @chuck tonight. Sorry."
        @test tweet_tokenize(s7, strip_handles=true, reduce_len=true) ==
            [":", "No", "place", "for", "tonight", ".", "Sorry", "."]

        s8 = "@mar_tin is a great developer. Contact him at mar_tin@email.com."
        @test tweet_tokenize(s8, strip_handles=true, reduce_len=true) ==
            ["is", "a", "great", "developer", ".", "Contact", "him", "at", "mar_tin@email.com", "."]
    end

    @test "Preserve Case" begin
        s9 = "@jrmy: I'm REALLY HAPPYYY about that! NICEEEE :D :P"
        @test tweet_tokenize(s9, preserve_case=false) ==
            ["@jrmy", ":", "i'm", "really", "happyyy", "about", "that", "!", "niceeee", ":D", ":P"]
    end

    @test "Test long sentences" begin
        s10 = "Photo: Aujourd'hui sur http://t.co/0gebOFDUzn Projet... http://t.co/bKfIUbydz2.............................. http://fb.me/3b6uXpz0L"
        @test tweet_tokenize(s10) ==
            ["Photo", ":", "Aujourd'hui", "sur", "http://t.co/0gebOFDUzn", "Projet", "...", "http://t.co/bKfIUbydz2", "...", "http://fb.me/3b6uXpz0L"]
    end
end
