# opening quote => ``
# closing quote => ''
# alone: -- ... `` ' : ; @#$%&?[](){}<>
# preserve : , ' in digits
# split: can-not, gim-me, lem-me, mor'n, d'ye, gon-na, got-ta, wan-na, 't-is, 't-was,
#   'll, 're, 've, n't, 's, 'm, 'd

struct TokenBuffer
  tokens::Vector{String}
  buffer::Vector{Char}
end

TokenBuffer() = TokenBuffer([], [])

function shift!(ts::TokenBuffer)
  isempty(ts.buffer) && return
  push!(ts.tokens, String(ts.buffer))
  empty!(ts.buffer)
  return
end

# TODO check for a word boundary
function matches(input::AbstractVector, s::String, i::Integer)
  for j = 1:length(s)
    input[i+j-1] == s[j] || return false
  end
  return true
end

const tokens = ["--", "...", "``"]
const suffixes = ["'ll", "'re", "'ve", "n't", "'s", "'m", "'d"]

function nltk_word_tokenize(input::AbstractVector)
  ts = TokenBuffer()
  i = 1
  while i <= length(input)
    if !isempty(ts.buffer)
      for suf in suffixes
        matches(input, suf, i) || continue
        shift!(ts)
        push!(ts.tokens, suf)
        i += length(suf)
      end
    end
    c = input[i]
    if c == '"'
      shift!(ts)
      push!(ts.tokens, "``")
    elseif ispunct(c)
      shift!(ts)
      push!(ts.tokens, string(c))
    elseif isspace(c)
      shift!(ts)
    else
      push!(ts.buffer, c)
    end
    # Closing quotes
    if !isspace(c) && i < length(input) && input[i+1] == '"'
      shift!(ts)
      push!(ts.tokens, "''")
      i += 1
    end
    i += 1
  end
  shift!(ts)
  return ts.tokens
end

# @btime nltk_word_tokenize("I don't know Dr. Who.")

nltk_word_tokenize(input::AbstractString) = nltk_word_tokenize(collect(input))
