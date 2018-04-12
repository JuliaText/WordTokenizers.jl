module WordTokenizers

export poormans_tokenize, punctuation_space_tokenize,
       penn_tokenize, improved_penn_tokenize, nltk_word_tokenize,
       tokenize,
       rulebased_split_sentences,
       split_sentences

include("words/simple.jl")
include("words/sedbased.jl")
include("sentences/sentence_splitting.jl")

const tokenize = nltk_word_tokenize
const split_sentences = rulebased_split_sentences

end # module
