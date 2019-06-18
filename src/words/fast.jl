# TODO: the input + idx combination should probably be replaced by a stream

"""
    TokenBuffer("foo bar")

Turns a string into a readable stream, used for building tokenisers. Utility
parsers such as `spaces` and `number` read characters from the stream and
into an array of tokens.

Parsers return `true` or `false` to indicate whether they matched anything
in the input stream. They can therefore be combined easily, e.g.

    spacesornumber(ts) = spaces(ts) || number(ts)

either skips whitespace or parses a number token, if possible.

The simplest possible tokeniser accepts any `character` with no token breaks:

    function tokenise(input)
        ts = TokenBuffer(input)
        while !isdone(ts)
            character(ts)
        end
        return ts.tokens
    end

    tokenise("foo bar baz") # ["foo bar baz"]

The second simplest splits only on spaces:

    function tokenise(input)
        ts = TokenBuffer(input)
        while !isdone(ts)
            spaces(ts) || character(ts)
        end
        return ts.tokens
    end

    tokenise("foo bar baz") # ["foo", "bar", "baz"]

See `nltk_word_tokenize` for a more advanced example.
"""
mutable struct TokenBuffer
    input::Vector{Char}
    buffer::Vector{Char}
    tokens::Vector{String}
    idx::Int
end

TokenBuffer(input) = TokenBuffer(input, [], [], 1)

TokenBuffer(input::AbstractString) = TokenBuffer(collect(input))

Base.getindex(ts::TokenBuffer, i = ts.idx) = ts.input[i]

function isdone(ts::TokenBuffer)
    done = ts.idx > length(ts.input)
    done && flush!(ts)
    return done
end

"""
    flush!(::TokenBuffer, tokens...)

TokenBuffer builds the current token as characters are read from the input. When
the end of the current token is detected, call `flush!` to finish it and append
it to the token stream. Optionally, give additional tokens to be added to the
stream after the current one.
"""
function flush!(ts::TokenBuffer, s...)
    if !isempty(ts.buffer)
        push!(ts.tokens, string(ts.buffer))
        empty!(ts.buffer)
    end
    push!(ts.tokens, s...)
    return
end

"""
    lookahead(::TokenBuffer, s; boundary = false)

Peek at the input to see if `s` is coming up next. `boundary` specifies whether
a word boundary should follow `s`.

    julia> lookahead(TokenBuffer("foo bar"), "foo")
    true

    julia> lookahead(TokenBuffer("foo bar"), "bar")
    false

    julia> lookahead(TokenBuffer("foo bar"), "foo", boundary = true)
    true

    julia> lookahead(TokenBuffer("foobar"), "foo", boundary = true)
    false
"""
function lookahead(ts::TokenBuffer, s; boundary = false)
    ts.idx + length(s) - 1 > length(ts.input) && return false
    for j = 1:length(s)
        ts.input[ts.idx-1+j] == s[j] || return false
    end
    if boundary
        next = ts.idx + length(s)
        next > length(ts.input) && return true
        (isletter(ts[next]) || ts[next] == '-') && return false
    end
    return true
end

"""
    character(::TokenBuffer)

Push the next character in the input into the buffer's current token.
"""
function character(ts)
    push!(ts.buffer, ts[])
    ts.idx += 1
    return true
end

"""
    spaces(::TokenBuffer)

If there is whitespace in the input, skip it, and flush the current token.
"""
function spaces(ts)
    isspace(ts[]) || return false
    flush!(ts)
    ts.idx += 1
    return true
end

"""
    atoms(::TokenBuffer, ["--", "...", ...])

Matches a set of atomic tokens, such as `...`, which should always be treated
as a single token, regardless of word boundaries.
"""
function atoms(ts, as)
    for a in as
        lookahead(ts, a) || continue
        flush!(ts, string(a))
        ts.idx += length(a)
        return true
    end
    (ispunct(ts[]) && ts[] != '.' && ts[] != '-') || return false
    flush!(ts, string(ts[]))
    ts.idx += 1
    return true
end

"""
    suffixes(::TokenBuffer, ["'ll", "'re", ...])

Matches tokens with suffixes, such as `you're`, that should be treated as
separate tokens.
"""
function suffixes(ts, ss)
    isempty(ts.buffer) && return false
    for s in ss
        lookahead(ts, s, boundary=true) || continue
        flush!(ts, string(s))
        ts.idx += length(s)
        return true
    end
    return false
end

"""
    replaces(::TokenBuffer, ["cannot"=>("can", "not"), ("freeeee"=>("free",), ...])

Matches tokens, and flushs their replacement to the stream.
The replacements should be a tuple of strings (potentially a 1-tuple), as this
can be used for splitting tokens.
For example, `cannot` would be split into `can` and `not`.
`freeeee` would be replaced with `free`
"""
function replaces(ts, ss)
    for (pat, subs) in ss
        lookahead(ts, pat, boundary=true) || continue
        flush!(ts, subs...)
        ts.idx += length(pat)
        return true
    end
    return false
end

"""
    openquote(::TokenBuffer)

Matches " used as an opening quote, and tokenises it as ``.
"""
function openquote(ts)
    ts[] == '"' || return false
    flush!(ts, "``")
    ts.idx += 1
    return true
end

"""
    closingquote(::TokenBuffer)

Matches " used as a closing quote, and tokenises it as ''.
"""
function closingquote(ts)
    ts[] == '"' || return false
    flush!(ts, "''")
    ts.idx += 1
    return true
end

"""
    number(::TokenBuffer)

Matches numbers such as `10,000.5`, preserving formatting.
"""
function number(ts, sep = (':', ',', '\'', '.'); check_sign = false)
    i = ts.idx
    if check_sign && ts[] ∈ ['+', '-'] && ( i == 1 || isspace(ts[i-1]))
        i += 1
    end

    i <= length(ts.input) && isdigit(ts[i]) || return false
    while i <= length(ts.input) && (isdigit(ts[i]) ||
                (ts[i] in sep && i < length(ts.input) && isdigit(ts[i+1])))
        i += 1
    end
    flush!(ts, string(ts[ts.idx:i-1]))
    ts.idx = i
    return true
end
