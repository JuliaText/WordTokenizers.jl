using Base.Test
using WordTokenizers
using TestSetExtensions

@testset "Targetted" begin
    @testset "Initials" begin
        @test 1 == length(rulebased_split_sentences("It is by A. Adamson, the famous author."))
        @test 1 == length(rulebased_split_sentences("It is by Z. Zeckerson, the famous author."))
        @test 1 == length(rulebased_split_sentences("It is by Bill R. Emerson, the famous author."))

        @test_broken 1 == (rulebased_split_sentences("It is by Ian I. Irving, the famous author."))

        @test 2 == length(rulebased_split_sentences("He doesn't and nor will I. It is best this way."))
    end

    @testset "period only" begin
        @test length(rulebased_split_sentences("a good day . . Yes"))==2
    end
end


@testset "Simple" begin
    split_sentences("Never going to give you up. Never going to let you down.") ==
        ["Never going to give you up.", "Never going to let you down."]
end


function test_sentence_splitting(split_sentences, raw)
    sents = split(raw, "\n") # Originally 1 sentence per line
    task = join(sents, " ") # Now all one lines
    output = strip.(split_sentences(task)) #strip off the extra spaces added

    @test output == sents
end


@testset ExtendedTestSet "turtles" begin
    #  https://simple.wikipedia.org/wiki/Turtle ,
    doc1 = """Turtles are the reptile order Testudines.
    They have a special bony or cartilaginous shell developed from their ribs that acts as a shield.
    The order Testudines includes both living and extinct species.
    The earliest fossil turtles date from about 220 million years ago.
    So turtles are one of the oldest surviving reptile groups and a more ancient group than lizards, snakes and crocodiles.
    Turtle have been very successful, and have almost world-wide distribution.
    But, of the many species alive today, some are highly endangered."""

    #  https://simple.wikipedia.org/wiki/Sea_turtle ,
    doc2 = """Sea turtles (Chelonioidea) are turtles found in all the world's oceans except the Arctic Ocean, and some species travel between oceans.
    The term is US English.
    In British English they are simply called "turtles"; fresh-water chelonians are called "terrapins" and land chelonians are called tortoises.
    There are seven types of sea turtles: Kemp's Ridley, Flatback, Green, Olive Ridley, Loggerhead, Hawksbill and the leatherback.
    All but the leatherback are in the family Chelonioidea.
    The leatherback belongs to the family Dermochelyidae and is its only member.
    The leatherback sea turtle is the largest, measuring six or seven feet (2 m) in length at maturity, and three to five feet (1 to 1.5 m) in width, weighing up to 2000 pounds (about 900 kg).
    Most other species are smaller, being two to four feet in length (0.5 to 1 m) and proportionally less wide.
    The Flatback turtle is found solely on the northern coast of Australia."""

    #  https://simple.wikipedia.org/wiki/Green_turtle
    doc3 = """Chelonia mydas, commonly known as the green turtle, is a large sea turtle belonging to the family Cheloniidae.
    It is the only species in its genus.
    It is one of the seven marine turtles, which are all endangered.
    Although it might have some green on its carapace (shell), the green turtle is not green.
    It gets its name from the fact that its body fat is green.
    It can grow up to 1 m (3 ft) long and weigh up to 160 kg (353 lb).
    They are an endangered species, especially in Florida and the Pacific coast of Mexico.
    They can also be found in warm waters around the world and are found along the coast of 140 countries.
    The female turtle lays eggs in nests she builds in the sand on the beaches.
    She uses the same beach that she was born on.
    During the nesting season in summer she can make up to five nests.
    She can lay as many as 135 eggs in a nest.
    The eggs take about two months to hatch.
    The baby turtles are about 50 mm (2 in) in length."""


    test_sentence_splitting(rulebased_split_sentences, doc1)
    test_sentence_splitting(rulebased_split_sentences, doc2)
    test_sentence_splitting(rulebased_split_sentences, doc3)
end

@testset "Difficult" begin
    test_sentence_splitting(rulebased_split_sentences,
        """Punkt knows that the periods in Mr. Smith and Johann S. Bach do not mark sentence boundaries.
        And sometimes sentences can start with non-capitalized words.
        i is a good variable name.""")
end
