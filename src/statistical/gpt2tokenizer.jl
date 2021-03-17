"""
struct GPT2Tokenizer
    vocab::Dict{String, Any}
    rank::Dict{Pair{String,String}, Int}
    cache::Dict{String, Tuple}
    pat::Regex
end
structure, To hold pretrained vocabulary map and merge rules for GPT2
"""
struct GPT2Tokenizer
    vocab::Dict{String, Any}
    rank::Dict{Pair{String,String}, Int}
    cache::Dict{String, Tuple}
    pat::Regex

    function GPT2Tokenizer(::Type{T};pat=r"'s|'t|'re|'ve|'m|'ll|'d| ?\p{L}+| ?\p{N}+| ?[^\s\p{L}\p{N}]+|\s+(?!\S)|\s+") where T<:PretrainedTokenizer

        vocab_file = @datadep_str tokenizer_files(T)[1]
        bfile = @datadep_str tokenizer_files(T)[2]

        vocab = Dict{String, Any}()
        rank = Dict{Pair{String, String}, Int}()
        cache = Dict{String, Tuple}()

        vocab = JSON.parsefile(vocab_file)

        open(bfile) do f
            for (i, line) ∈ enumerate(eachline(f))
                if i==1
                    identity
                else
                    pair = Pair(split(line," ")...)
                    rank[pair] = i-1
                end
            end
        end
        new(vocab, rank, cache, pat)
    end
end

"""
load(ty::Type{T}) where T<:PretrainedTokenizer
Initializes the GPT2Tokenizer and loads the vocab and merges files from `DataDeps`
#Example
```julia-repl
julia> tokenizer = load(GPT2)

```
"""
function load(ty::Type{T}) where T<:PretrainedTokenizer
    GPT2Tokenizer(T)
end

"""
Returns Dictionary of utf-8 encoding and corresponding unicode strings for Byte-Pair Encoding.
"""
function bytes_to_unicode()
    bs = [33:255...]
    cs = bs[:]
    n=0
    for b in 0:255
        if b ∉ bs
            append!(bs, b)
            append!(cs, 256+n)
            n+=1
        end
    end
    cs = [Char(n) for n in cs]
    Dict(zip(bs,cs))
end

toStrTuple(x::Vector{String})=toStrTuple(join(x))
function toStrTuple(x::AbstractString)
    fs = intern.(split(chop(x), ""))
    push!(fs, intern(x[end]*""))
    filter!((x)-> x != "", fs)
    Tuple(fs)
end

"""
get_pairs(word::NTuple{})
Returns set of pairs in a word. Word is a tuple of strings.
"""
function get_pairs(word::NTuple{})
    pairs = Set{Pair{}}()
    prev_char = word[1]
    for char in word[2:end]
        push!(pairs, Pair(prev_char, char))
        prev_char = char
    end
    pairs
end

lowestpair(pairs::Set{Pair{}},tokenizer::GPT2Tokenizer) = lowestpair(collect(pairs), tokenizer::GPT2Tokenizer)
lowestpair(pairs::Vector{Pair{}}, tokenizer::GPT2Tokenizer) = argmin(
    sizehint!(Dict(
    map(pairs) do p
        p=>get(tokenizer.rank, p, typemax(Int))
    end),
          length(pairs))
    )


function bpe(token::String, tokenizer::GPT2Tokenizer)

    haskey(tokenizer.cache, token) && return tokenizer.cache[token]
    word = toStrTuple(token)
    pairs = get_pairs(word)
    isempty(pairs) && return token

    while true
        pair = lowestpair(pairs, tokenizer)
        !haskey(tokenizer.rank, pair) && break
        first, second = pair
        new_word=Vector{String}()
        i=1

        while i <= length(word)

            try
                j = findnext(isequal(first), word, i)
                append!(new_word, word[i:j-1])
                i=j
            catch
                append!(new_word,word[i:end])
                break
            end

            if word[i]==first && i<=length(word)-1 && word[i+1]==second
                push!(new_word, first*second)
                i+=2
            else
                push!(new_word, word[i])
                i+=1
            end
        end
        new_word = Tuple(new_word)
        word = new_word

        if length(word)==1
            break
        else
            pairs = get_pairs(word)
        end
    end
    tokenizer.cache[token] = word
    word
end

"""
tokenize(text::String, tokenizer::GPT2Tokenizer)
Implements tokenization of input text. This tokenizer doesn't include unknown and special tokens because
of its byte-level BPE tokenization. GPT2 model is only trained on end token `<|endoftext|>`. Has to be
manually added after the tokenization.
GPT2 Tokenizer treats whitespace as unicode character `\u0120 (Ġ)` before a word.

# Example
```julia-repl
julia> tokens = tokenize("Hi! How you doin", tokenizer)
6-element Array{String,1}:
 "Hi"
 "!"
 "ĠHow"
 "Ġyou"
 "Ġdo"
 "in"
```
"""
function tokenize(text::String, tokenizer::GPT2Tokenizer)
    mapping = bytes_to_unicode()
    tokens=Vector{String}()
    matches = map(eachmatch(tokenizer.pat, text)) do m
        m.match
    end
    for token in matches
        token = join([mapping[Int(b)] for b in token])
        append!(tokens, [string(bpe_token) for bpe_token in bpe(token, tokenizer)])
    end
    tokens
end

"""
ids_from_tokens(tokens::Vector{String}, tokenizer::GPT2Tokenizer)
Returns respective ids of tokens from pretrained vocabulary map

# Example
```julia-repl
julia> tokens = tokenize("Hi! How you doin", tokenizer)
6-element Array{String,1}:
 "Hi"
 "!"
 "ĠHow"
 "Ġyou"
 "Ġdo"
 "in"

julia> ids_from_tokens(tokens, tokenizer)
6-element Array{Int64,1}:
 17250
     0
  1374
   345
   466
   259
```
"""
function ids_from_tokens(tokens::Vector{String}, tokenizer::GPT2Tokenizer)
    map(tokens) do x
        last(get(tokenizer.vocab, x, 0))
    end
end

function sentence_from_tokens_gpt2(tk::Array{String,1})
    sen = join(tk)
    sen = replace(sen, "Ġ" => " ")
    sen = strip(sen)
    return sen
end
