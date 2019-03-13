const EMOTICONS_REGEX = r"""(?x)
            (?:
             [<>]?
             [:;=8]
             [\-o\*\']?
             [\)\]\(\[dDpP/\:\}\{@\|\\]
             |
             [\)\]\(\[dDpP/\:\}\{@\|\\]
             [\-o\*\']?
             [:;=8]
             [<>]?
             |
             <3
            )"""


const URLS = r"""(?x)
        (?:
        https?:
          (?:
            /{1,3}
            |
            [a-z0-9%]
          )
          |
          [a-z0-9.\-]+[.]
          (?:[a-z]{2,13})
          /
        )
        (?:
          [^\s()<>{}\[\]]+
          |
          \([^\s()]*?\([^\s()]+\)[^\s()]*?\)
          |
          \([^\s]+?\)
        )+
        (?:
          \([^\s()]*?\([^\s()]+\)[^\s()]*?\)
          |
          \([^\s]+?\)
          |
          [^\s`!()\[\]{};:'".,<>?«»“”‘’]
        )
        |
        (?:
                (?<!@)
          [a-z0-9]+
          (?:[.\-][a-z0-9]+)*
          [.]
          (?:[a-z]{2,13})
          \b
          /?
          (?!@)
        )
      """


const PHONE_NUMBERS = r"""(?x)
           (?:
             (?:
               \+?[01]
               [ *\-.\)]*
             )?
             (?:
               [\(]?
               \d{3}
               [ *\-.\)]*
             )?
             \d{3}
             [ *\-.\)]*
             \d{4}
           )"""


const HTML_TAGS = r"""<[^>\s]+>"""
const ASCII_ARROWS = r"""[\-]+>|<[\-]+"""
const TWITTER_USERNAME = r"""(?:@[\w_]+)"""
const TWITTER_HASHTAGS = r"""(?:\#+[\w_]+[\w\'_\-]*[\w_]+)"""
const EMAIL_ADDRESSES = r"""[\w.+-]+@[\w-]+\.(?:[\w-]\.?)+[\w-]"""
const WORDS_WITH_APOSTROPHE_DASHES = r"""(?:[^\W\d_](?:[^\W\d_]|['\-_])+[^\W\d_])"""
const NUMBERS_FRACTIONS_DECIMALS = r"""(?:[+\-]?\d+[,/.:-]\d+[+\-]?)"""
const ELLIPSIS_DOTS = r"""(?:\.(?:\s*\.){1,})"""
const WORDS_WITHOUT_APOSTROPHE_DASHES = r"""(?:[\w_]+)"""


# Core tokenizing regex
const WORD_REGEX = Regex("(?i:" * join([URLS.pattern
                    PHONE_NUMBERS.pattern
                    EMOTICONS_REGEX.pattern
                    HTML_TAGS.pattern
                    ASCII_ARROWS.pattern
                    TWITTER_USERNAME.pattern
                    TWITTER_HASHTAGS.pattern
                    EMAIL_ADDRESSES.pattern
                    WORDS_WITH_APOSTROPHE_DASHES.pattern
                    NUMBERS_FRACTIONS_DECIMALS.pattern
                    WORDS_WITHOUT_APOSTROPHE_DASHES.pattern
                    ELLIPSIS_DOTS.pattern
                    r"(?:\S)".pattern
                    ], "|")
                    * ")"
                    )

const HANG_REGEX = r"""([^a-zA-Z0-9])\1{3,}"""

"""
    html_entities(ts::TokenBuffer; remove_illegal=true)

Removes entities from text by converting them to their corresponding unicode character.

`remove_illegal::Bool` If `true`, entities that can't be converted are
removed. Otherwise, entities that can't be converted are kept "as
is".

HTML entity can be named or encoded in Decimal/Hex form
- Named_entity : "&Delta;" => "Δ",
- Decimal : "&#916;" => "Δ",
- Hex : "&#x394;" => "Δ",
However for bytes (hex) 80-9f are interpreted in Windows-1252

"""
function html_entity(ts::TokenBuffer, remove_illegal=true)
    (ts.idx + 1 > length(ts.input) || ts.input[ts.idx] != '&' ) && return false
    if ts.input[ts.idx + 1] != '#'    # Entity is of the type "&Delta;" => "Δ"
        i = ts.idx + 1
        while i <= length(ts.input) && isascii(ts[i]) &&
                (isdigit(ts[i]) || islowercase(ts[i]) || isuppercase(ts[i]))
            i += 1
        end
        (i > length(ts.input) || ts[i] != ';') && return false
        entity = lookupname(HTML_Entities.default, String(ts[ts.idx+1:i-1]))
        isempty(entity) && !remove_illegal && return false
        !isempty(entity) && push!(ts.buffer, entity[1])
        ts.idx = i + 1
        return true
    else
        number = -1
        i = ts.idx + 2
        if ts.input[ts.idx + 2] != 'x'    # Entity is of the type "&#916;" => "Δ"
            while i <= length(ts.input) && isdigit(ts[i])
                i += 1
            end
            (i > length(ts.input) || ts[i] != ';') && return false
            if ((ts.idx + 2 ) == i)
                !remove_illegal && return false
                ts.idx +=3
                return true
            end
            (number = parse(Int, String(ts[ts.idx+2:i-1]), base=10))
        else   # Entity is of the type "&#x394;" => "Δ"
            i += 1
            base16letters = ('a', 'b', 'c', 'd', 'e', 'f')
            while i <= length(ts.input) && (isdigit(ts[i]) || ts[i] in base16letters)
                i += 1
            end
            (i > length(ts.input) || ts[i] != ';') && return false

            if (ts.idx + 3) == i
                !remove_illegal && return false
                ts.idx += 4
                return true
            end
            number = parse(Int, String(ts[ts.idx+3:i-1]), base=16)
        end

        windows_1252_chars = ['€', '\u81', '‚', 'ƒ', '„', '…', '†', '‡', 'ˆ', '‰',
                          'Š', '‹', 'Œ', '\u8d','Ž', '\u8f', '\u90', '‘', '’',
                          '“', '”', '•', '–', '—', '˜', '™', 'š', '›', 'œ',
                          '\u9d', 'ž', 'Ÿ']
        if 0x80 <= number <= 0x9F
            push!(ts.buffer, windows_1252_chars[number - 127])
            ts.idx = i + 1
            return true
        end
        if (number <= 0 || !Unicode.isassigned(number))
            !remove_illegal && return false
            ts.idx = i + 1
        else
            push!(ts.buffer, Char(number))
        ts.idx = i + 1
        end
    end
    return true
end

"""
    lookbehind(ts::TokenBuffer)
A helper function for twitter_handle. Checks if the beginning of the detected
handle is preceded by alphanumeric or special chars like('_', '!', '@', '#', '\$', '%', '&', '*')
"""

function lookbehind(ts::TokenBuffer,
                match_pattern = ('_', '!', '@', '#', '$', '%', '&', '*'))
    ts.idx == 1 && return false

    c = ts[ts.idx - 1]
    ( islowercase(c) || isdigit(c) || isuppercase(c) || c ∈ match_pattern ) && return true

    return false
end


"""
    twitter_handle(ts::TokenBuffer)

For removing Twitter Handles. If it detects a twitter handle, then it jumps to
makes the index of TokenBuffer to the desired location skipping the handle.
"""
function twitter_handle(ts)

    (ts.idx + 2 > length(ts.input) || ts.input[ts.idx] != '@' ) && return false
    lookbehind(ts) && return false

    i = ts.idx + 1
    while i <= length(ts.input) &&
              ( isascii(ts[i]) && (isdigit(ts[i]) || islowercase(ts[i]) ||
               isuppercase(ts[i]) || ts[i] == '_'))
        i += 1
    end
    (i <= length(ts.input)) && (i == ts.idx + 1 || ts[i] == '@') && return false

    ts.idx = i
    return true
end


"""
    reduce_all_repeated(ts::TokenBuffer)

For handling repeated characters like "helloooooo" -> :hellooo".

"""
function reduce_all_repeated(ts)
    ts.idx + 4 > length(ts.input) && return false

    (ts[ts.idx] == '\n' || ts[ts.idx] != ts[ts.idx + 1] ||
              ts[ts.idx] != ts[ts.idx + 2]) && return false

    i = ts.idx + 3
    while i <= length(ts.input) && ts[i] == ts[ts.idx]
        i += 1
    end
    for j in 1:3
        push!(ts.buffer, ts[ts.idx])
    end
    ts.idx = i
    return true
end

"""
    safe_text(ts::TokenBuffer)

This feature covers up for the characters where the main tokenizing function lacks
For example - "........" -> "..." and this is detected by the key tokenizer as a
single token of "..."
"""
function safe_text(ts)
    ts.idx + 4 > length(ts.input) && return false

    (
       (isascii(ts[ts.idx]) && ( islowercase(ts[ts.idx]) ||
                   isuppercase(ts[ts.idx]) ||  isdigit(ts[ts.idx]))) ||
              ts[ts.idx] != ts[ts.idx + 1] ||
              ts[ts.idx] != ts[ts.idx + 2] )  && return false

    i = ts.idx + 3

    while i <= length(ts.input) && ts[i] == ts[ts.idx]
        i += 1
    end

    for j in 1:3
        push!(ts.buffer, ts[ts.idx])
    end
    ts.idx = i

    return true
end


"""
    replace_html_entities(input::AbstractString, remove_illegal=true)


`input::AbstractString` The string on which HTML entities need to be replaced
`remove_illegal::Bool` If `true`, entities that can't be converted are
removed. Otherwise, entities that can't be converted are kept "as
is".

"""
function replace_html_entities(input::AbstractString; remove_illegal=true)
    ts = TokenBuffer(input)
    isempty(input) && return ""

    while !isdone(ts)
        html_entity(ts, remove_illegal) || character(ts)
    end
    return ts.tokens[1]
end


"""
    function  pre_process(input::AbstractString, strip_handle::Bool,
                            reduce_len::Bool)

This function processes on the input string and optionally remove twitter handles
and reduce length of repeated characters (like "waaaaay" -> "waaay")
and for elements like ".........?????? -> "...???" to increase the performance
of the key tokenizer.
"""
function pre_process(input::AbstractString, strip_handle::Bool, reduce_len::Bool)
    ts = TokenBuffer(input)
    isempty(input) && return ""

    while !isdone(ts)
        (strip_handle && twitter_handle(ts)) ||   # Remove username handles
        (reduce_len && reduce_all_repeated(ts)) ||    # Reduce Lengthening
        safe_text(ts) ||  # Shorten some sequences of characters
        character(ts)
    end

    return ts.tokens[1]
end

"""
    tweet_tokenize(input::AbstractString) => tokens

Twitter-aware tokenizer, designed to be flexible and
easy to adapt to new domains and tasks.

The basic logic is following:

1. The regular expressions are made for WORD_REGEX (core tokenizer), HANG_REGEX
   and EMOTICONS_REGEX.
2  Replacing HTML entities, tweet handles, reducing length of repeated characters
   and other features, make it suitable for tweets.
3. The String is tokenized and returned.
4. `preserve_case` By default is set to `true`. If it is set to `false`,
   then the tokenizer will downcase everything except for emoticons.

Example:

```
julia> tweet_tokenize("This is a cooool #dummysmiley: :-) :-P <3 and some arrows < > -> <--")

16-element Array{SubString{String},1}:
 "This"
 "is"
 "a"
 "cooool"
 "#dummysmiley"
 ":"
 ":-)"
 ":-P"
 "<3"
 "and"
 "some"
 "arrows"
 "<"
 ">"
 "->"
 "<--"
```
"""
function tweet_tokenize(source::AbstractString;
                            strip_handle=false,
                            reduce_len=false,
                            preserve_case=true )

    length(source) == 0 && return []
    # Fix HTML Character entities
    source = replace_html_entities(source)

    length(source) == 0 && return []
    safe_text = pre_process(source, strip_handle, reduce_len)

    # The key tokenizing function begins
    tokens = collect((m.match for m in eachmatch(WORD_REGEX,
                                            safe_text,
                                            overlap=false)))

  # Alter the case with preserving it for emoji
    if  !preserve_case
        for (index, word) in enumerate(tokens)
            if !occursin(EMOTICONS_REGEX, word)
                tokens[index] = lowercase(word)
            end
        end
    end

    return tokens
end
