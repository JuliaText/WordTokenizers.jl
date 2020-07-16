"""
struct SentencePieceModel
  vocab::Array{String,1}
  logprob::Array{Float64,1}
end

structure, To hold vocabulary,log probability and index  
"""
struct SentencePieceModel
    vocab::Array{String,1}
    logprob::Array{Float64,1}
    unk_id::Int
end

"""
    load(ty::Type{T}, name::String; unk_token="<unk>") where T<:PretrainedTokenizer
use to initialize the Sentencepiecemodel by loading `DataDeps`
# Example
```julia-repl
julia> spm = load(ALBERT_V1,"albert_xxlarge_v1_30k-clean.vocab", unk_token="<unk>")
```
"""
function load(ty::Type{T}, filenum::Int=1 ; unk_token="<unk>") where T<:PretrainedTokenizer
    filepath = @datadep_str tokenizer_files(ty)[filenum]
    name = tokenizer_files(ty)[filenum]
    filepath = "$filepath/$name"
    load(filepath, unk_token=unk_token)  
end

"""
    load(path; unk_token="<unk>") 
use to initialize the SentencePieceModel by providing `vocab filepath`
"""    
function load(path; unk_token="<unk>")
    vocab = readlines(path)
    vocabnew = split.(vocab, "\t")
    voc = String[]
    logprob = Float64[]
    for i in 1:length(vocab)
        vocab1 = vocabnew[i][1]
        vocab1 = replace(vocab1, "▁"=>"_")
        push!(voc, vocab1)
        logp = vocabnew[i][2]
        logp =  parse(Float64, logp)
        push!(logprob, logp)    
    end
    unk_id = findall(x->x==unk_token, voc)
    length(unk_id) == 0 && throw(UndefVarError(:unk_token)) 
    spm = SentencePieceModel(voc, logprob, unk_id[1])
    return spm
end

# to get index of given string
function getindex(sp::SentencePieceModel, text)
    id_list = findall(x->x==text, sp.vocab)
    length(id_list) == 0 && return sp.unk_id #unk token index 
    return id_list[1]
end

"""
struct Nodes 
    text::String
    score::Float32
    index::Int64
    start::Int
    en::Int
end
Utility structure, To hold the results of the `forward pass` (the forward Viterbi lattice)
hold the token token string, score, vocabulary index, start and end character position   
"""
struct Nodes 
    text::String
    score::Float32
    index::Int64
    start::Int
    en::Int
end

"""
    decode_forward(sp::SentencePieceModel,text::String)
Perform `forward pass` (the forward Viterbi lattice) operation detail can be found [here](https://tejasvaidhyadev.github.io/blog/Sentencepiece).
Return all output, as an Array{String,1}
# Example
```julia-repl
julia> seq = ["To","be","or","not"]
julia> node = WordTokenizers.decode_forward(spm, "I love julia language")
21-element Array{WordTokenizers.Nodes,1}:
 WordTokenizers.Nodes("I", -Inf32, 1, 1, 1)
 WordTokenizers.Nodes(" ", -Inf32, 1, 2, 2)
 WordTokenizers.Nodes("l", -Inf32, 1, 3, 3)
 WordTokenizers.Nodes("lo", -9.56041f0, 1416, 3, 4)
 WordTokenizers.Nodes("lov", -11.0086f0, 5943, 3, 5)
 WordTokenizers.Nodes("love", -10.7128f0, 4584, 3, 6)
 WordTokenizers.Nodes(" ", -Inf32, 1, 7, 7)
 WordTokenizers.Nodes("j", -Inf32, 1, 8, 8)
 WordTokenizers.Nodes("ju", -9.96107f0, 2143, 8, 9)
 WordTokenizers.Nodes("ul", -19.4301f0, 1288, 9, 10)
 WordTokenizers.Nodes("uli", -21.02407f0, 6244, 9, 11)
 WordTokenizers.Nodes("ulia", -22.49547f0, 19590, 9, 12)
 WordTokenizers.Nodes(" ", -Inf32, 1, 13, 13)
 WordTokenizers.Nodes("l", -Inf32, 1, 14, 14)
 WordTokenizers.Nodes("la", -8.6488f0, 532, 14, 15)
 WordTokenizers.Nodes("lan", -9.78918f0, 1805, 14, 16)
 WordTokenizers.Nodes("lang", -11.6118f0, 9950, 14, 17)
 WordTokenizers.Nodes("gu", -21.9203f0, 3074, 17, 18)
 WordTokenizers.Nodes("gua", -23.776f0, 15259, 17, 19)
 WordTokenizers.Nodes("ag", -34.1531f0, 3303, 19, 20)
 WordTokenizers.Nodes("language", -11.1965f0, 7021, 14, 21)
``` 
"""
function decode_forward(sp::SentencePieceModel, text::String)
    results = Array{Nodes, 1}(undef, length(text))
    scores = fill(-Inf, length(text))
    scores[1] = 0
    for char_end in eachindex(text)
        for char_start in 1:char_end
            if text[char_start:char_end] in sp.vocab
                subtokenid = getindex(sp, text[char_start:char_end])[1]
                local_score = scores[char_start] + sp.logprob[subtokenid]
                if local_score > scores[char_end]   
                    results[char_end] = Nodes(text[char_start:char_end], local_score, subtokenid, char_start, char_end)
                    scores[char_end] = local_score
                end
            end
        end
        if scores[char_end] == -Inf
            results[char_end] = Nodes(text[char_end-1:char_end], -Inf, 1, char_end-1, char_end)
            scores[char_end] = 0
        end
        if scores[char_end] == 0
            results[char_end] = Nodes(text[char_end:char_end], -Inf, 1, char_end, char_end)
        end
    end
    return(results)
end

"""
    decode_backward(sp::SentencePieceModel,text::String)
inputs nodes (i.e. output of `decode_forward`) and
Return output of backword pass as mentioned [here](https://tejasvaidhyadev.github.io/blog/Sentencepiece), as an Array{String,1}
# Example
'''julia-repl
julia> WordTokenizers.decode_backward(spm ,node)
8-element Array{Any,1}:
 WordTokenizers.Nodes("language", -11.1965f0, 7021, 14, 21)
 WordTokenizers.Nodes(" ", -Inf32, 1, 13, 13)
 WordTokenizers.Nodes("ulia", -22.49547f0, 19590, 9, 12)
 WordTokenizers.Nodes("j", -Inf32, 1, 8, 8)
 WordTokenizers.Nodes(" ", -Inf32, 1, 7, 7)
 WordTokenizers.Nodes("love", -10.7128f0, 4584, 3, 6)
 WordTokenizers.Nodes(" ", -Inf32, 1, 2, 2)
 WordTokenizers.Nodes("I", -Inf32, 1, 1, 1)
'''
"""
function decode_backward(sp::SentencePieceModel, nodes)
    next_nodes = nodes[end]
    best_seq = []
    
    while next_nodes.start > 1
        node_value = next_nodes
        next_nodes = nodes[(node_value.start)-1]
        push!(best_seq, node_value)
    end
    push!(best_seq, next_nodes)
    return(best_seq)
end

"""
    tokenizer(sp::SentencePieceModel,text::AbstractString)
It does all the preprocessing step needed and perform `decode_forward` and `decode_backward`
ouput tokenize tokens as Array{String,1}
"""
function tokenizer(sp::SentencePieceModel, text::AbstractString)
    tks = []
    text = replace(text, " " => "_")
    if text[1] != '_'
        text = "_" * text
    end
    output = decode_forward(sp, text)
    tokens = decode_backward(sp, output)
    tokens = reverse(tokens)
    for node in tokens
        push!(tks, node.text)
    end
    tks = string.(tks)
    return(tks)
    
end

"""
    (sp::SentencePieceModel)(text::AbstractString)
It does all the preprocessing step needed and perform `decode_forward` and `decode_backward`.
"""
function (sp::SentencePieceModel)(text::AbstractString)
    tokenizer(sp, text)
end

"""
    ids_from_tokens(spm::SentencePieceModel, tk::Array{String,1})
given tokens it provide its indices
"""     
ids_from_tokens(spm::SentencePieceModel, tk::Array{String,1}) = 
    map(tk) do x
        getindex(spm, x)
    end

"""
    sentence_from_tokens(tk::Array{String,1})
given tokens it provide its sentences
"""
function sentence_from_tokens(tk::Array{String,1})
    sen = tk[1]
    for i in 1:(length(tk)-1)
        sen = sen*tk[i+1]
    end
    sen = replace(sen, "_" => " ")
    if sen[1] == ' '
        sen = sen[2:end]
    end
    return(sen)    
end
