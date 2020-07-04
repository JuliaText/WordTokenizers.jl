
module WordTokenizers

using HTML_Entities
using StrTables
using Unicode
using GoogleDrive
using DataDeps


export poormans_tokenize, punctuation_space_tokenize,
       penn_tokenize, improved_penn_tokenize, nltk_word_tokenize,
       tweet_tokenize,
       tokenize,
       rulebased_split_sentences,
       split_sentences,
       set_tokenizer, set_sentence_splitter,
       rev_tokenize, rev_detokenize,
       toktok_tokenize

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

abstract type Pretrained_tokenizer end
abstract type Albert <: Pretrained_tokenizer end

const list_vocab = Dict{DataType, Vector{String}}()
function tokenizer_files(::Type{T}) where T<:Pretrained_tokenizer 
    get!(list_vocab,T) do
        String[]
    end
end
function __init__()
    vectors = [
               ("albert_large_v2_vocab",
                " ~800kb download.",
                "922a6eac5d42605ea2ab7a72e39b07a76a9efc4f864f2bc52131f2dbbd5d08d9",
               "https://drive.google.com/drive/folders/1K_n_n5-8m2juumbQNt07_JTdNp0a-bFJ"),
]

    for (depname, description, sha, link) in vectors
        register(DataDep(depname,
                         """
                         sentencepiece albert vocabulary file by google research .
                         Website: https://github.com/google-research/albert
                         Author: Google Research
                         Year: 2015
                         Licence: Apache License 2.0

                         size of file $description
                         """,
                         link,
                         sha,
                         fetch_method = google_download))
       
            append!(tokenizer_files(Albert), ["$depname"])
       
            
      
    end
end



end # module
