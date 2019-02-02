##################################################
#Experimental API
export Words, Sentences

const tokenizers = [poormans_tokenize, punctuation_space_tokenize,
       penn_tokenize, improved_penn_tokenize, nltk_word_tokenize, tweet_tokenize]
const sentence_splitters = [rulebased_split_sentences]

const Words = tokenize
const Sentences = split_sentences

for rule in [tokenizers; sentence_splitters]
    @eval function Base.split(str::T, ::typeof($(rule))) where T<:AbstractString
        $rule(str)
    end

    @eval function Base.split(str::T, ::typeof($(rule))) where T<:SubString
        $rule(str)
    end
end
