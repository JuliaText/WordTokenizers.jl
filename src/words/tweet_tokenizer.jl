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
A helper function for strip_twitter_handle. Checks if the beginning of the detected
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
    strip_twitter_handle(ts::TokenBuffer)

For removing Twitter Handles. If it detects a twitter handle, then it jumps to
makes the index of TokenBuffer to the desired location skipping the handle.
"""
function strip_twitter_handle(ts)

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
        (strip_handle && strip_twitter_handle(ts)) ||   # Remove username handles
        (reduce_len && reduce_all_repeated(ts)) ||    # Reduce Lengthening
        safe_text(ts) ||  # Shorten some sequences of characters
        character(ts)
    end

    return ts.tokens[1]
end

function flushaboutindex!(ts::TokenBuffer, uptoidx)
    flush!(ts, String(ts[ts.idx:uptoidx]))
    ts.idx = uptoidx + 1
    return true
end

const forehead = ['>', '<']
const eyes = [':' ';' '=' '8']
const nose = ['-','o','*','\'']
const mouth = [')', ']', '}', '(', '[', '{', 'd', 'D', 'p', 'P', '\\', '/', ':', '@', '|']

"""
    function emoticons(ts::TokenBuffer)

This function checks for the emoticons for the type `{forehead}{eyes}{nose}{mouth}
explicitely in this order, with {forehead} and {nose} being optional

Example:
- `:)`, `;p`    # (without nose and forehead)
- `:-)`, `:-p`  # (with nose)
- `>:)`         # (with forehead)
- `>:-)`        # (with forehead and nose)

Also checks for `<3` emoji
"""
function emoticons(ts)
    ts.idx + 1 > length(ts.input) && return false
    idx = ts.idx

    ts[idx] ∈ eyes && (
        (ts[idx + 1] ∈ mouth && return flushaboutindex!(ts, idx + 1)) ||
        (idx + 2 <= length(ts.input) && ts[idx + 1] ∈ nose && ts[idx + 2] ∈ mouth &&
            return flushaboutindex!(ts, idx + 2)) ||
        return false
    )

    idx + 2 <= length(ts.input) && ts[idx] ∈ forehead && ts[idx + 1] ∈ eyes && (
            (ts[idx + 2] ∈ mouth && return flushaboutindex!(ts, idx + 2)) ||
            (idx + 3 <= length(ts.input) && ts[idx + 2] ∈ nose &&
                ts[idx + 3] ∈ mouth && return flushaboutindex!(ts, idx + 3)) ||
            return false
    )

    ts[idx] == '<' && ts[idx + 1] == '3' && return flushaboutindex!(ts, idx + 1)

    return false
end

"""
    function emoticonsreverse(ts::TokenBuffer)

This function checks for the emoticons in reverse order to those of `function emoticons`
explicitely in this order `{mouth}{nose}{eyes}{forehead}`, with {forehead} and {nose} being optional

Example:
- `(:`, `d:`    # (without nose and forehead)
- `(-:`, `d-:`  # (with nose)
- (:<`          # (with forehead)
- `(-:<`        # (with forehead and nose)

"""
function emoticonsreverse(ts)
    ts.idx + 1 > length(ts.input) && return false
    idx = ts.idx

    ts[idx] ∈ mouth && (
        ts[idx + 1] ∈ eyes && (
            (ts[idx + 2] ∈ forehead && return flushaboutindex!(ts, idx + 2)) ||
            return flushaboutindex!(ts, idx+1)
        ) ||
        ts[idx + 1] ∈ nose && (
            ts[idx + 2] ∈ eyes && (
                (ts[idx + 3] ∈ forehead && return flushaboutindex!(ts, idx + 3)) ||
                return flushaboutindex!(ts, idx + 3)
            )
        )
    )

    return false
end

"""
    htmltags(ts::TokenBuffer)

Matches the HTML tags which contain no space inside the tags.
"""
function htmltags(ts)
    (ts.idx + 2 > length(ts.input) || ts[ts.idx] != '<'
                || ts[ts.idx + 1] == '>') && return false

    i = ts.idx
    while i <= length(ts.input) && ts[i] != '>'
        isspace(ts[i]) && return false
        i += 1
    end
    i > length(ts.input) && return false

    return flushaboutindex!(ts, i)
end


# To-Do : Find a way to make arrowsascii repeatedly check for recheck
"""
    arrowsascii(ts::TokenBuffer)

Matches the ascii arrows - made up of arrows like `<--` and `--->`
"""
function arrowsascii(ts)
    (
        ts.idx + 1 > length(ts.input) ||
        (
            (ts[ts.idx] != '<' || ts[ts.idx + 1] != '-' ) &&
            (ts[ts.idx] != '-')
        )
    )   && return false

    i = ts.idx
    if ts[i] == '<'
        i += 1
        while i <= length(ts.input) && ts[i] == '-'
            i += 1
        end
        return flushaboutindex!(ts, i - 1)
    end
    while i <= length(ts.input) && ts[i] == '-'
        i += 1
    end
    ts[ts.idx] == '>' && return flushaboutindex!(ts, i)
end


# Checks the string till non word char appears, so takes relatively more time.
"""
    emailaddresses(ts)

Matches for email addresses.
"""
function emailaddresses(ts)
    ts.idx + 4 > length(ts.input) && return false

    i = ts.idx
    while i + 3 <= length(ts.input) && isascii(ts[i]) &&
            (isdigit(ts[i]) || islowercase(ts[i]) ||
                isuppercase(ts[i]) || ts[i] ∈ ['.', '+', '-', '_'])
        i += 1
    end
    (i == ts.idx || ts[i] != '@') && return false

    i += 1
    j = i
    while i + 2 <= length(ts.input) && isascii(ts[i]) &&
            (isdigit(ts[i]) || islowercase(ts[i]) ||
                isuppercase(ts[i]) || ts[i] == '-' || ts == '_')
        i += 1
    end

    (j == i || ts[i] != '.') && return false

    j = i
    last_dot = i
    i += 1

    while i <= length(ts.input) && isascii(ts[i]) &&
            (isdigit(ts[i]) || islowercase(ts[i]) ||
                isuppercase(ts[i]) || ts[i] ∈ ['-', '_'])

        if i + 1 < length(ts.input) && ts[i + 1] == '.'
            i += 1
            last_dot = i
        end

        i += 1
    end

    i > last_dot + 1 && i > j + 2 && return flushaboutindex!(ts, i - 1)

    return false
end

"""
    twitterhashtags(ts)

Matches for twitter hashtags.
"""
function twitterhashtags(ts)
    (ts.idx + 2 > length(ts.input) || ts[ts.idx] != '#' ||
                    ts[ts.idx + 1] ∈ ['\'', '-']) && return false

    i = ts.idx + 1
    last_word_char = i

    while i <= length(ts.input) && isascii(ts[i]) &&
                        (isdigit(ts[i]) || islowercase(ts[i]) ||
                         isuppercase(ts[i]) || ts[i] ∈ ['_', '\'', '-'])

        if ts[i] ∉  ['\'', '-']
            last_word_char = i
        end

        i += 1
    end

    last_word_char >= ts.idx + 2 && ts[ts.idx + 1] ∉ ['\'', '-'] &&
            ts[last_word_char] ∉ ['\'', '-'] && return flushaboutindex!(ts, last_word_char)

    return false
end

"""
    twitterusername(ts)

Matches for twitter usernames.
"""
function twitterusername(ts)
    (ts.idx + 1 > length(ts.input) || ts[ts.idx] != '@' ) && return false

    i = ts.idx + 1
    while i <= length(ts.input) && isascii(ts[i]) &&
                        (isdigit(ts[i]) || islowercase(ts[i]) ||
                         isuppercase(ts[i]) || ts[i] == '_')
        i += 1
    end
    i > ts.idx + 1 && return flushaboutindex!(ts, i - 1)

    return false
end

"""
    ellipsis_dots(ts)

Matches for ellipsis and dots, ignoring the spaces, tabs, newlines between them.
"""
function ellipsis_dots(ts)
    (ts.idx + 1 > length(ts.input) || ts[ts.idx] != '.' ) && return false

    i = ts.idx + 1
    last_dot = ts.idx

    while i <= length(ts.input) && (isspace(ts[i]) || ts[i] == '.')
        if ts[i] == '.'
            last_dot = i
        end
        i += 1
    end

    last_dot != ts.idx && return flushaboutindex!(ts, last_dot)

    return false
end

"""
    words_including_apostrophe_dashes(ts)

TokenBuffer matcher for words that may or maynot have dashes or apostrophe in it.
"""
function words_including_apostrophe_dashes(ts)
    (ts.idx + 1 > length(ts.input) ||  !(isascii(ts[ts.idx]) &&
                (islowercase(ts[ts.idx]) || isuppercase(ts[ts.idx])
                        || isdigit(ts[ts.idx]) || ts[ts.idx] == '_' ))) && return false

    has_apostrophe_dashes = false
    i = ts.idx + 1
    last_char = ts.idx

    if isuppercase(ts[ts.idx]) || islowercase(ts[ts.idx])
        while i <= length(ts.input) && isascii(ts[i]) &&
                (islowercase(ts[i]) || isuppercase(ts[i]) || ts[i] ∈ ['_', '\'', '-'])
            if has_apostrophe_dashes == false && ts[i] ∈ ['\'', '-']
                has_apostrophe_dashes = true
            else
                last_char = i
            end
            i += 1
        end
    end

    has_apostrophe_dashes && last_char != ts.idx && return flushaboutindex!(ts, last_char)

    while i <= length(ts.input) && isascii(ts[i]) && (isdigit(ts[i]) ||
                    islowercase(ts[i]) || isuppercase(ts[i]) || ts[i] == '_')
        i += 1
    end

    return flushaboutindex!(ts, i - 1)
end

"""
    nltk_casual_phonenumbers(ts)

The TokenBuffer function for nltk's tweet tokenizer regex for phonenumbers.
"""
function nltk_phonenumbers(ts)
    (ts.idx + 5 > length(ts.input) || !(isdigit(ts[ts.idx]) ||
                                    ts[ts.idx] ∈ ['+', '('] )) && return false

    i = ts.idx
    optional_1_confirmed = false

    # Checking for the part 1 of regex which is optional
    if ts[i] == '+'
        ts[i + 1] ∈ ['0', '1'] || return false
        i += 2

        while i <= length(ts.input) && ts[i] ∈ [' ', '*', '-', '.', ')']
            i += 1
        end

        i + 5 > length(ts.input) && return false

        optional_1_confirmed = true
    elseif ts[i] ∈ ['0', '1']
        i += 1

        while i <= length(ts.input) && ts[i] ∈ [' ', '*', '-', '.', ')']
            i += 1
        end

        i + 5 > length(ts.input) && return false

        if i - ts.idx > 1  || ts[i] == '('
            optional_1_confirmed = true
        end
    end

    if i == ts.idx || optional_1_confirmed
        # This is called when either the first part is sure to present or absent, otherwise next one called
        if ts[i] == '('
            i += 1

            for repeat in 1:2 # repeat is unused variable inside loop
                if !(i + 3 <= length(ts.input) && isdigit(ts[i]) && isdigit(ts[i + 1]) &&
                                            isdigit(ts[i + 2]))

                    return false
                end

                i += 3
                while i <= length(ts.input) && ts[i] ∈ [' ', '*', '-', '.', ')']
                    i += 1
                end
            end

            !(i + 3 <= length(ts.input) && isdigit(ts[i]) && isdigit(ts[i + 1]) &&
                        isdigit(ts[i + 2]) && isdigit(ts[i + 3])) && return false

            return flushaboutindex!(ts, i + 3)
        else
            if !(i + 3 <= length(ts.input) && isdigit(ts[i]) && isdigit(ts[i + 1]) &&
                                        isdigit(ts[i + 2]))

                return false
            end
            i += 3

            while i <= length(ts.input) && ts[i] ∈ [' ', '*', '-', '.', ')']
                i += 1
            end

            if !(i + 3 <= length(ts.input) && isdigit(ts[i]) && isdigit(ts[i + 1]) &&
                                        isdigit(ts[i + 2]))

                return false
            end
            i += 3
            j = i

            while i <= length(ts.input) && ts[i] ∈ [' ', '*', '-', '.', ')']
                i += 1
            end

            i + 3 <= length(ts.input) && isdigit(ts[i]) && isdigit(ts[i + 1]) &&
                    isdigit(ts[i + 2]) && isdigit(ts[i + 3]) && return flushaboutindex!(ts, i + 3)

            isdigit(ts[j]) && return flushaboutindex!(ts, j)

            return false
        end
    else
        # Checks if the pattern fits with or without part 1, if both do then go for bigger one.
        index_including_1 = 0
        index_excluding_1 = 0
        j = i

        # Checking if including the first optional part of regex matches the pattern.

        if !(i + 3 <= length(ts.input) && isdigit(ts[i]) && isdigit(ts[i + 1]) &&
                                            isdigit(ts[i + 2]))
            index_including_1 = -1
        end
        i += 3

        while i <= length(ts.input) && ts[i] ∈ [' ', '*', '-', '.', ')']
            i += 1
        end

        if !(i + 3 <= length(ts.input) && isdigit(ts[i]) && isdigit(ts[i + 1]) &&
                                            isdigit(ts[i + 2]))
            index_including_1 = -1
        end
        i += 3
        j = i

        while i <= length(ts.input) && ts[i] ∈ [' ', '*', '-', '.', ')']
            i += 1
        end

        if i + 3 <= length(ts.input) && isdigit(ts[i]) && isdigit(ts[i + 1]) &&
             isdigit(ts[i + 2]) && isdigit(ts[i + 3]) && index_including_1 == 0
            index_including_1 = i + 3
        elseif isdigit(ts[j]) && index_including_1 == 0
            index_including_1 = j
        end

        # Checking  if including the first optional part of regex matches the pattern.
        i = ts.idx

        if !(i + 3 <= length(ts.input) && isdigit(ts[i]) && isdigit(ts[i + 1]) &&
                                            isdigit(ts[i + 2]))
            index_excluding_1 = -1
        end
        i += 3

        while i <= length(ts.input) && ts[i] ∈ [' ', '*', '-', '.', ')']
            i += 1
        end

        if !(i + 3 <= length(ts.input) && isdigit(ts[i]) && isdigit(ts[i + 1]) &&
                                            isdigit(ts[i + 2]))
            index_excluding_1 = -1
        end
        i += 3
        j = i

        while i <= length(ts.input) && ts[i] ∈ [' ', '*', '-', '.', ')']
            i += 1
        end

        if i + 3 <= length(ts.input) && isdigit(ts[i]) && isdigit(ts[i + 1]) &&
                    isdigit(ts[i + 2]) && isdigit(ts[i + 3]) && index_excluding_1 == 0
            index_excluding_1 = i + 3
        elseif isdigit(ts[j]) && index_excluding_1 == 0
            index_excluding_1 = j
        end

        # Flushing out the bigger of the two.
        index_including_1 <= 0 && index_excluding_1 <= 0 && return false
        index_excluding_1 > index_including_1 && return flushaboutindex!(ts, index_excluding_1)
        return flushaboutindex!(ts, index_including_1)
    end

    return false
end

"""
    extra_phonenumbers(ts)

Extra matching patterns for phone numbers.
"""
function extra_phonenumbers(ts)
    return false
end

"""
    nltk_url1(ts)

Matches the url patterns starting with `http/https`.
"""
function nltk_url1(ts)
    ts.idx + 3 > length(ts.input) && return false
    i = ts.idx

    # Checking for part 1 of regex
    if ts[i:i+3] == ['h', 't', 't', 'p'] # Check if url starts with pattern - https?:(?:\/{1,3}|[a-z0-9%])
        i += 4
        i + 2 > length(ts.input) && return false

        if ts[i] == 's'
            i += 1
        end

        ts[i] == ':' || return false
        i += 1

        if i >= length(ts.input) || !(isascii(ts[i]) && (islowercase(ts[i]) ||
                     isdigit(ts[i]) || ts[i] == '%' || ts[i] == '/'))
            return false
        end

        i += 1
    else # Check if url starts with the regex pattern - [a-z0-9.\-]+[.](?:[a-z]{2,13})\/
        last_dot = ts.idx

        while i <= length(ts.input) && isascii(ts[i]) && (islowercase(ts[i]) || isdigit(ts[i]) ||
                                                            ts[i] == '.' || ts[i] == '-')
            if ts[i] == '.'
                last_dot = i
            elseif !islowercase(ts[i])
                last_dot = ts.idx
            end

            i += 1
        end

        if i + 2 > length(ts.input) || last_dot <= ts.idx + 1 || i - last_dot > 14 ||
                                    i - last_dot <= 2 || ts[i] != '/'
            return false
        end
        i += 1
    end

    # URL is supposed to have 2 more parts.
    # Both Part 2 and Part 3 each having 3 possible alternatives.
    # Part 2 occurs at least once and Part 3 exactly once.
    # After every match of the first part, we keep a track if the second one follows it.
    # and store the maximum index in `index_matched`.
    # Finally, we flush about the index = index_matched then.

    index_matched = ts.idx

    while i + 1 <= length(ts.input) && !(isspace(ts[i]))

        # Check if part 2 matches otherwise break.
        # Part 2 could be one of the three patterns.
        #   i.   ` \([^\s]+?\)`
        #   ii.  `\([^\s()]*?\([^\s()]+?\)[^\s()]*?\)`
        #   iii. `[^\s()<>{}\[\]]+`
        if ts[i] == '(' # Checking for i. and ii. above.
            i += 1
            (i > length(ts.idx) || isspace(ts[i])) && break
            j = i

            while j <= length(ts.idx) && ts[j] != ')' && ts[j] != '(' && !isspace(ts[j])
                j += 1
            end

            (j > length(ts.idx) || isspace(ts[j])) && break

            if ts[j] == ')' # Checking for i.
                j - i <= 1 && break
                i = j
            else # Checking for ii.
                i = j
                i > length(ts.idx) && break

                while j <= length(ts.idx) && ts[j] != ')' && ts[j] != '(' && !isspace(ts[j])
                    j += 1
                end

                (j > length(ts.idx) || isspace(ts[j]) || ts[j] == '(') && break
                j - i <= 1 && break
                j += 1

                while j <= length(ts.idx) && ts[j] != ')' && ts[j] != '(' && !isspace(ts[j])
                    j += 1
                end

                (j > length(ts.idx) || isspace(ts[j]) || ts[j] == '(') && break
                i = j
            end
            i += 1
        else # Checking for iii.
            (isspace(ts[i])|| ts[i] ∈ [')', '<', '>', '{', '}', '[', ']'] ) && break
            i += 1
        end

        i > length(ts.input)  && break
        k = i # Just for temporarily storing i.

        # Check if part 3 matches otherwise continue.
        # Part 3 could be one of the three patterns.
        #   i.   `\([^\s()]*?\([^\s()]+?\)[^\s()]*?\)`
        #   ii.  `[^\s`!()\[\]{};:'".,<>?«»“”‘’]`
        #   iii. ` \([^\s]+?\)`
        if ts[i] == '(' # Check for part i. and iii.

            i += 1
            (i > length(ts.idx) || isspace(ts[i])) && continue
            j = i

            while j <= length(ts.idx) && ts[j] != ')' && ts[j] != '(' && !isspace(ts[j])
                j += 1
            end

            (j > length(ts.idx) || isspace(ts[j])) && continue

            if ts[j] == ')' # Check for part iii.
                j - i <= 1 && break
                i = j
            else # Check for part i.
                i = j
                i > length(ts.idx) && continue

                while j <= length(ts.idx) && ts[j] != ')' && ts[j] != '(' && !isspace(ts[j])
                    j += 1
                end

                (j > length(ts.idx) || isspace(ts[j]) || ts[j] == '(') && continue
                j - i <= 1 && continue

                j += 1
                while j <= length(ts.idx) && ts[j] != ')' && ts[j] != '(' && !isspace(ts[j])
                    j += 1
                end

                (j > length(ts.idx) || isspace(ts[j]) || ts[j] == '(') && continue
                i = j
            end
            index_matched = i
            i += 1
        else # Check for part ii.
            isspace(ts[i]) && break
            ts[i] ∈ ['`', '!', ')', '[', ']', '{', '}', ';', ':', '\'', '"', '.',
                     ',', '<', '>', '?', '«', '»', '“', '”', '‘', '’'] && continue
            index_matched = i
        end
        i = k
    end

    index_matched == ts.idx && return false
    return flushaboutindex!(ts, index_matched)
end

function nltk_url2(ts)
    return false
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
                            preserve_case=true)

    phonenumbers(ts) = nltk_phonenumbers(ts) || extra_phonenumbers(ts)
    # urls(ts) = nltk_url1(ts) || nltk_url2(ts)

    length(source) == 0 && return []
    # Fix HTML Character entities
    source = replace_html_entities(source)

    length(source) == 0 && return []
    safe_text = pre_process(source, strip_handle, reduce_len)

    # The key tokenizing function begins
    ts = TokenBuffer(safe_text)
    isempty(safe_text) && return ts.tokens

    # # TODO: OpenQuotes and Closing quotes
    while !isdone(ts)
        spaces(ts) && continue
        emoticons(ts) ||
        emoticonsreverse(ts) ||
        htmltags(ts) ||
        arrowsascii(ts) ||
        twitterhashtags(ts) ||
        ellipsis_dots(ts) ||
        # urls(ts) || # urls must be called before words.
        twitterusername(ts) ||
        emailaddresses(ts) || # emailaddresses must be called before words
        phonenumbers(ts) || # Phone numbers must be called before numbers.
        atoms(ts, []) ||
        words_including_apostrophe_dashes(ts) ||
        number(ts, check_sign = true) ||
        character(ts)
    end

    tokens = ts.tokens

    # tokens = collect((m.match for m in eachmatch(WORD_REGEX,
    #                                         safe_text,
    #                                         overlap=false)))

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
