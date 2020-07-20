"""
struct SentencePieceModel
  vocab_map::Dict{String, Tuple{Float64, Int}}
  unk_id::Int
end
structure, To hold unknown token index and map of vocabulary to log probability and index   
"""
struct SentencePieceModel
    vocab_map::Dict{String, Tuple{Float64, Int}}
    unk_id::Int
end

"""
    load(ty::Type{T}, filenum::Int=1; unk_token="<unk>") where T<:PretrainedTokenizer
use to initialize the `SentencePieceModel` by loading the file from `DataDeps`
# Example
```julia-repl
julia> spm = load(ALBERT_V1)
```
"""
function load(ty::Type{T}, filenum::Int=1; unk_token="<unk>") where T<:PretrainedTokenizer
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
    vocab_path = readlines(path)
    vocabnlogp = split.(vocab_path, "\t")
    vocab_map = Dict(tok=>(parse(Float64, logp), index) for (index, (tok, logp)) in enumerate(vocabnlogp))
    if haskey(vocab_map, unk_token)
        unk_id = vocab_map[unk_token][2]
    else
        throw(DomainError(unk_token, "Unknown token is not in the vocabulary"))
    end 
    spm = SentencePieceModel(vocab_map, unk_id)
    return spm
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
    results = Array{Nodes, 1}(undef, lastindex(text)) 
    scores = fill(-Inf, lastindex(text))
    scores[1] = 0
    for char_end in eachindex(text)
        for char_start in eachindex(text)
            char_start > char_end && break
            subtoken = SubString(text, char_start:char_end)
            if haskey(sp.vocab_map, subtoken)
                subtokenid =  sp.vocab_map[subtoken][2]
                local_score = scores[char_start] + sp.vocab_map[subtoken][1]
                if local_score > scores[char_end]   
                    results[char_end] = Nodes(SubString(text, char_start:char_end), local_score, subtokenid, char_start, char_end)
                    scores[char_end] = local_score
                end
            end
        end
        if scores[char_end] == -Inf
            results[char_end] = Nodes(SubString(text, prevind(text, char_end):char_end), -Inf, 1, char_end-1, char_end)
            scores[char_end] = 0
        end
        if scores[char_end] == 0
            results[char_end] = Nodes(SubString(text, char_end:char_end), -Inf, 1, char_end, char_end)
        end
    end
    return results
end

"""
    decode_backward(sp::SentencePieceModel, nodes::Array{Nodes, 1}, text::AbstractString)
inputs nodes (i.e. output of `decode_forward`) and
Return output of backword pass as mentioned [here](https://tejasvaidhyadev.github.io/blog/Sentencepiece), as an Array{Nodes,1}
# Example
'''julia-repl
julia> WordTokenizers.decode_backward(spm, node, text)
8-element Array{WordTokenizers.Nodes,1}:
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
function decode_backward(sp::SentencePieceModel, nodes::Array{Nodes,1}, text::AbstractString)
    next_nodes = nodes[end]
    best_seq = Nodes[]
    
    while next_nodes.start > 1
        node_value = next_nodes
        next_nodes = nodes[prevind(text, node_value.start)]
        push!(best_seq, node_value)
    end
    push!(best_seq, next_nodes)
    return best_seq
end

"""
    tokenizer(sp::SentencePieceModel,text::AbstractString)
It does all the preprocessing step needed and perform `decode_forward` and `decode_backward`
ouput tokenize tokens as Array{String,1}
"""
function tokenizer(sp::SentencePieceModel, text::AbstractString)
    text = replace(text, " " => "▁")
    if text[1] != '▁'
        text = "▁" * text
    end
    output = decode_forward(sp, text)
    tokens = decode_backward(sp, output, text)
    tokens = reverse(tokens)
    tks = [node.text for node in tokens]
    return tks
    
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
function ids_from_tokens(spm::SentencePieceModel, tk::Array{String,1})  
    map(tk) do x
        last(get(spm.vocab_map, x, spm.unk_id))
    end
end

"""
    sentence_from_tokens(tk::Array{String,1})
given tokens it provide its sentences
"""
function sentence_from_tokens(tk::Array{String,1})
    sen = join(tk)
    sen = replace(sen, "▁" => " ")
    sen = strip(sen)
    return sen     
end
