"""
    poormans_tokenize

Tokenizes by removing punctuation and splitting on spaces
"""
function poormans_tokenize(source::AbstractString)
    cleaned = filter(s->!ispunct(s), source)
    split(cleaned)
end

"""
    punctuation_space_tokenize

Tokenizes by removing punctuation, unless it occurs inside of a word.
"""
function punctuation_space_tokenize(source::AbstractString)
    preprocced = source
    pass1=replace(preprocced,r"[[:punct:]]*[[:space:]][[:punct:]]*"," ")
    pass2=replace(pass1,r"[[:punct:]]*$|^[[:punct:]]*","")
    split(pass2)
end
