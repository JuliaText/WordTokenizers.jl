
module WordTokenizers

using HTML_Entities
using StrTables
using Unicode
using GoogleDrive
using DataDeps

abstract type Pretrained_tokenizer end
abstract type Albert_Version1 <: Pretrained_tokenizer end
abstract type Albert_Version2 <: Pretrained_tokenizer end

export poormans_tokenize, punctuation_space_tokenize,
       penn_tokenize, improved_penn_tokenize, nltk_word_tokenize,
       tweet_tokenize,
       tokenize,
       rulebased_split_sentences,
       split_sentences,
       set_tokenizer, set_sentence_splitter,
       rev_tokenize, rev_detokenize,
       toktok_tokenize
export Albert_Version1, Albert_Version2, load, tokenizer, sentence_from_tokens, ids_from_tokens
export pretrained
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



const pretrained = Dict{DataType, Vector{String}}()
function tokenizer_files(::Type{T}) where T<:Pretrained_tokenizer 
    get!(pretrained,T) do
        String[]
    end
end
function __init__()
    vectors_albertversion1 = [
               ("albert_base_v1_30k-clean.vocab",
                "albert base version1 of size ~800kb download.",
                "1de4ad94a1b98f5f5f2c75af0f52bc85714d67b8578aa8f7650521bb123335c0",
                "https://raw.githubusercontent.com/tejasvaidhyadev/ALBERT.jl/master/src/Vocabs/albert_base_v1_30k-clean.vocab"),
                ("albert_large_v1_30k-clean.vocab",
                " albert large version1 of size ~800kb download.",
                "1de4ad94a1b98f5f5f2c75af0f52bc85714d67b8578aa8f7650521bb123335c0",
                "https://raw.githubusercontent.com/tejasvaidhyadev/ALBERT.jl/master/src/Vocabs/albert_large_v1_30k-clean.vocab"),
                ("albert_xlarge_v1_30k-clean.vocab",
                "albert xlarge version1 of size ~800kb download",
                "1de4ad94a1b98f5f5f2c75af0f52bc85714d67b8578aa8f7650521bb123335c0",
                "https://raw.githubusercontent.com/tejasvaidhyadev/ALBERT.jl/master/src/Vocabs/albert_xlarge_v1_30k-clean.vocab"),
                ("albert_xxlarge_v1_30k-clean.vocab",
                "albert xxlarge version1 of size ~800kb download",
                "1de4ad94a1b98f5f5f2c75af0f52bc85714d67b8578aa8f7650521bb123335c0",
                "https://raw.githubusercontent.com/tejasvaidhyadev/ALBERT.jl/master/src/Vocabs/albert_xxlarge_v1_30k-clean.vocab")
]

    for (depname, description, sha, link) in vectors_albertversion1
        register(DataDep(depname,
                         """
                         sentencepiece albert vocabulary file by google research .
                         Website: https://github.com/google-research/albert
                         Author: Google Research
                         Licence: Apache License 2.0
                         $description
                         """,
                         link,
                         sha,
                         fetch_method = google_download))
       
            append!(tokenizer_files(Albert_Version1), ["$depname"])                    
    end
    vectors_albertversion2 = [
               ("albert_base_v2_30k-clean.vocab",
                "albert base version2 of size ~800kb download.",
                "1de4ad94a1b98f5f5f2c75af0f52bc85714d67b8578aa8f7650521bb123335c0",
                "https://raw.githubusercontent.com/tejasvaidhyadev/ALBERT.jl/master/src/Vocabs/albert_base_v2_30k-clean.vocab"),
                ("albert_large_v2_30k-clean.vocab",
                " albert large version2 of size ~800kb download.",
                "1de4ad94a1b98f5f5f2c75af0f52bc85714d67b8578aa8f7650521bb123335c0",
                "https://raw.githubusercontent.com/tejasvaidhyadev/ALBERT.jl/master/src/Vocabs/albert_large_v2_30k-clean.vocab"),
                ("albert_xlarge_v2_30k-clean.vocab",
                "albert xlarge version2 of size ~800kb download.",
                "1de4ad94a1b98f5f5f2c75af0f52bc85714d67b8578aa8f7650521bb123335c0",
                "https://raw.githubusercontent.com/tejasvaidhyadev/ALBERT.jl/master/src/Vocabs/albert_xlarge_v2_30k-clean.vocab"),
                ("albert_xxlarge_v2_30k-clean.vocab",
                "albert xxlarge version2 of size ~800kb download.",
                "1de4ad94a1b98f5f5f2c75af0f52bc85714d67b8578aa8f7650521bb123335c0",
                "https://raw.githubusercontent.com/tejasvaidhyadev/ALBERT.jl/master/src/Vocabs/albert_xxlarge_v2_30k-clean.vocab")
]

    for (depname, description, sha, link) in vectors_albertversion2
        register(DataDep(depname,
                         """
                         sentencepiece albert vocabulary file by google research .
                         Website: https://github.com/google-research/albert
                         Author: Google Research
                         Licence: Apache License 2.0
                         $description
                         """,
                         link,
                         sha,
                         fetch_method = google_download))
       
            append!(tokenizer_files(Albert_Version2), ["$depname"])                    
    end
end
end # module
