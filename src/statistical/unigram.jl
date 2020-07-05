"""
struct Sentencepiecemodel
  vocab::Array{String,1}
  logprob::Array{Float64,1}
end
structure, To hold vocabulary,log probability and index
    
"""
struct Sentencepiecemodel
  vocab::Array{String,1}
  logprob::Array{Float64,1}
end
function load(ty::Type{T}, name::String) where T<:Pretrained_tokenizer
        filepath = @datadep_str name
        filepath = "$filepath/$name"
        print(filepath)
        load(filepath)  
end
    

function load(path)
    vocab = readlines(path)
    vocabnew = split.(vocab , "\t")
    vo = []
    for i in 1:30000
        vocab1 = vocabnew[i][1]
        vocab1 = replace(vocab1,"▁"=>"_")
        push!(vo,vocab1)
    end
    vocab1 = convert(Array{String,1},vo)
    logprob = []
    for i in 1:30000
        logp = vocabnew[i][2]
        push!(logprob,logp)    
    end
    logp = convert(Array{String,1},logprob)
    logp =parse.(Float64,logprob)
    spm = Sentencepiecemodel(vocab1,logp)
return spm
end

# to get index of given string
function getindex(sp::Sentencepiecemodel,text)
    findall(x->x==text, sp.vocab)[1]
end
"""
struct Nodes 
    text::String
    score::Float32
    index::Int64
    start::Int
    en::Int
end
Utility structure, To hold the results of the forward pass (the forward Viterbi lattice)
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
    decode_forward(sp::Sentencepiecemodel,text::String)
Return all possible ngrams generated from sequence of items, as an Array{String,1}
# Example
```julia-repl
julia> seq = ["To","be","or","not"]
julia> a = everygram(seq,min_len=1, max_len=-1)
 10-element Array{Any,1}:
  "or"          
  "not"         
  "To"          
  "be"                  
  "or not" 
  "be or"       
  "be or not"   
  "To be or"    
  "To be or not"
```
   
"""
function decode_forward(sp::Sentencepiecemodel, text::String)
    results = Array{Nodes, 1}(undef, length(text))
    scores = fill(-Inf, length(text))
    scores[1] =0
    for char_end in 1:length(text)
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
    decode_forward(sp::Sentencepiecemodel,text::String)
Return all possible ngrams generated from sequence of items, as an Array{String,1}
"""


function Decode_backward1(sp::Sentencepiecemodel, nodes)
    next_nodes = nodes[end]
    best_seq = []
    
    while next_nodes.start > 1
        node_value = next_nodes
        next_nodes = nodes[(node_value.start)-1]
        push!(best_seq,node_value)
    end
    push!(best_seq,next_nodes)
    return(best_seq)
end
"""
    Tokenizer(sp::Sentencepiecemodel,text)
given spm path and text it tokenized you string
It does all the preprocessing step needed 
"""

function Tokenizer(sp::Sentencepiecemodel, text)
    tks=[]
    text = replace(text, " " => "_")
    if text[1] != '_'
        text = "_" * text
    end
    output = decode_forward(sp, text)
    tokens = Decode_backward1(sp, output)
    tokens = reverse(tokens)
    for node in tokens
        push!(tks, node.text)
    end
    tks = string.(tks)
    return(tks)
    
end
"""
    ids_from_tokens(tk::Array{String,1})
given tokens it provide its indices
"""
      
function ids_from_tokens(tk)
idlist=[]
for i in tk
    idx = getindex(spm, i)
    push!(idlist, idx)
end
return convert.(Int,idlist)
end

"""
    sentence_from_tokens(tk::Array{String,1})
given sentence from its tokens
"""

function sentence_from_tokens(tk)
    sen=tk[1]
    for i in 1:(length(tk)-1)
        sen= sen*tk[i+1]
    end
    sen = replace(sen,"_" => " ")
    if sen[1] == ' '
        sen = sen[2:end]
    end
    return(sen)    
end
