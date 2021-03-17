
module WordTokenizers

using HTML_Entities
using StrTables
using Unicode
using DataDeps, JSON, InternedStrings

abstract type PretrainedTokenizer end

export poormans_tokenize, punctuation_space_tokenize,
       penn_tokenize, improved_penn_tokenize, nltk_word_tokenize,
       tweet_tokenize,
       tokenize,
       rulebased_split_sentences,
       split_sentences,
       set_tokenizer, set_sentence_splitter,
       rev_tokenize, rev_detokenize,
       toktok_tokenize
export ALBERT_V1, ALBERT_V2, load, tokenizer, sentence_from_tokens, ids_from_tokens, GPT2, GPT2Tokenizer, tokenize, sentence_from_tokens_gpt2
export PretrainedTokenizer, tokenizer_files
include("words/fast.jl")

include("words/simple.jl")
include("words/nltk_word.jl")
include("words/reversible_tokenize.jl")
include("words/sedbased.jl")
include("words/tweet_tokenizer.jl")
include("sentences/sentence_splitting.jl")
include("words/TokTok.jl")

include("set_method_api.jl")
include("split_api.jl")

include("statistical/unigram.jl")
include("statistical/gpt2tokenizer.jl")

const pretrained = Dict{DataType, Vector{String}}()
function tokenizer_files(::Type{T}) where T<:PretrainedTokenizer
    get!(pretrained,T) do
        String[]
    end
end

include("statistical/Vocab_DataDeps.jl")

function __init__()
    init_vocab_datadeps()
end

end # module
