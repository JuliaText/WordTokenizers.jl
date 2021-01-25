function rulebased_split_sentences(sentences)
    sentences = replace(sentences, r"([?!.])\s" => Base.SubstitutionString("\\1\n"))

    sentences = postproc_splits(sentences)
    split(sentences, "\n"; keepempty=false)
end


function replace_til_no_change(input, pattern, replacement)
    while(occursin(pattern, input))
        input = replace(input, pattern => replacement)
    end
    input
end


"""
     postproc_splits(sentences)

Applies heuristic rules to repair sentence splitting errors.
Developed for use as postprocessing for the GENIA sentence
splitter on PubMed abstracts, with minor tweaks for
full-text documents.

`sentences` should be a string, with line breaks on sentence boundaries.
Returns a similar string, but more correct.

Based on
https://github.com/ninjin/geniass/blob/master/geniass-postproc.pl
Which is
(c) 2010 Sampo Pyysalo. No rights reserved, i.e. do whatever you like with this.
Which draws in part on heuristics included in Yoshimasa Tsuruoka's
medss.pl script.

"""
function postproc_splits(sentences::AbstractString)
    # Before we do anything remove windows line-ends
    sentences = replace(sentences, "\r" => "")

    # breaks sometimes missing after "?", "safe" cases
    sentences = replace(sentences, r"\b([a-z]+\?) ([A-Z][a-z]+)\b" => Base.SubstitutionString("\\1\n\\2"))
    # breaks sometimes missing after "." separated with extra space, "safe" cases
    sentences = replace(sentences, r"\b([a-z]+ \.) ([A-Z][a-z]+)\b" => Base.SubstitutionString("\\1\n\\2"))

    # no breaks producing lines only containing sentence-ending punctuation
    sentences = replace(sentences, r"\n([.!?]+)\n" => Base.SubstitutionString("\\1\n"))

    # no breaks inside parens/brackets. (To protect against cases where a
    # pair of locally mismatched parentheses in different parts of a large
    # document happens to match, limit size of intervening context. As this
    # is not an issue in cases where there are no intervening brackets,
    # allow an unlimited length match in those cases.)

    # unlimited length for no intevening parens/brackets
    sentences = replace_til_no_change(sentences, r"\[([^\[\]\(\)]*)\n([^\[\]\(\)]*)\]", s"[\1 \2]")
    sentences = replace_til_no_change(sentences, r"\(([^\[\]\(\)]*)\n([^\[\]\(\)]*)\)", s"(\1 \2)")
    # standard mismatched with possible intervening
    sentences = replace_til_no_change(sentences, r"\[([^\[\]]{0,250})\n([^\[\]]{0,250})\]", s"[\1 \2]")
    sentences = replace_til_no_change(sentences, r"\(([^\(\)]{0,250})\n([^\(\)]{0,250})\)", s"(\1 \2)")
    # ... nesting to depth one
    sentences = replace_til_no_change(sentences, r"\[((?:[^\[\]]|\[[^\[\]]*\]){0,250})\n((?:[^\[\]]|\[[^\[\]]*\]){0,250})\]", s"[\1 \2]")
    sentences = replace_til_no_change(sentences, r"\(((?:[^\(\)]|\([^\(\)]*\)){0,250})\n((?:[^\(\)]|\([^\(\)]*\)){0,250})\)", s"(\1 \2)")


    # no break after periods followed by a non-uppercase "normal word"
    # (i.e. token with only lowercase alpha and dashes, with a minimum
    # length of initial lowercase alpha).
    sentences = replace(sentences, r"\.\n([a-z]{3}[a-z-]{0,}[ \.\:\,])" => s". \1")


    # No break after an single letter other than I, which could be an initial in a name
    sentences = replace(sentences, r"(\b[A-HJ-Z]\.)\n" => s"\1 ")

    # no break before CC ...
    sentences = replace(sentences, r"\n(and )" => s" \1")
    sentences = replace(sentences, r"\n(or )" => s" \1")
    sentences = replace(sentences, r"\n(but )" => s" \1")
    sentences = replace(sentences, r"\n(nor )" => s" \1")
    sentences = replace(sentences, r"\n(yet )" => s" \1")
    # or IN. (this is nothing like a "complete" list...)
    sentences = replace(sentences, r"\n(of )" => s" \1")
    sentences = replace(sentences, r"\n(in )" => s" \1")
    sentences = replace(sentences, r"\n(by )" => s" \1")
    sentences = replace(sentences, r"\n(as )" => s" \1")
    sentences = replace(sentences, r"\n(on )" => s" \1")
    sentences = replace(sentences, r"\n(at )" => s" \1")
    sentences = replace(sentences, r"\n(to )" => s" \1")
    sentences = replace(sentences, r"\n(via )" => s" \1")
    sentences = replace(sentences, r"\n(for )" => s" \1")
    sentences = replace(sentences, r"\n(with )" => s" \1")
    sentences = replace(sentences, r"\n(that )" => s" \1")
    sentences = replace(sentences, r"\n(than )" => s" \1")
    sentences = replace(sentences, r"\n(from )" => s" \1")
    sentences = replace(sentences, r"\n(into )" => s" \1")
    sentences = replace(sentences, r"\n(upon )" => s" \1")
    sentences = replace(sentences, r"\n(after )" => s" \1")
    sentences = replace(sentences, r"\n(while )" => s" \1")
    sentences = replace(sentences, r"\n(during )" => s" \1")
    sentences = replace(sentences, r"\n(within )" => s" \1")
    sentences = replace(sentences, r"\n(through )" => s" \1")
    sentences = replace(sentences, r"\n(between )" => s" \1")
    sentences = replace(sentences, r"\n(whereas )" => s" \1")
    sentences = replace(sentences, r"\n(whether )" => s" \1")

    # no sentence breaks in the middle of specific abbreviations
    sentences = replace(sentences, r"(\be\.)\n(g\.)" => s"\1 \2")
    sentences = replace(sentences, r"(\bi\.)\n(e\.)" => s"\1 \2")
    sentences = replace(sentences, r"(\bi\.)\n(v\.)" => s"\1 \2")

    # no sentence break after specific abbreviations
    sentences = replace(sentences, r"(\be\. ?g\.)\n" => s"\1 ")
    sentences = replace(sentences, r"(\bi\. ?e\.)\n" => s"\1 ")
    sentences = replace(sentences, r"(\bi\. ?v\.)\n" => s"\1 ")
    sentences = replace(sentences, r"(\bvs\.)\n" => s"\1 ")
    sentences = replace(sentences, r"(\bcf\.)\n" => s"\1 ")
    sentences = replace(sentences, r"(\bDr\.)\n" => s"\1 ")
    sentences = replace(sentences, r"(\bMr\.)\n" => s"\1 ")
    sentences = replace(sentences, r"(\bMs\.)\n" => s"\1 ")
    sentences = replace(sentences, r"(\bMrs\.)\n" => s"\1 ")




    # possible TODO: filter excessively long / short sentences
    sentences
end
