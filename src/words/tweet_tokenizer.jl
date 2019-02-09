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


# WORD_REGEX performs poorly on these patterns:
const HANG_REGEX = r"""([^a-zA-Z0-9])\1{3,}"""

# Regex for replacing HTML_Entities
const HTML_ENTITIES_REGEX = r"""&(#?(x?))([^&;\s]+);"""

const HANDLES_REGEX = r"""(?x)
                (?<![A-Za-z0-9_!@#\$%&*])@(([A-Za-z0-9_]){20}(?!@))
                |
                (?<![A-Za-z0-9_!@#\$%&*])@(([A-Za-z0-9_]){1,19})(?![A-Za-z0-9_]*@)
                """


"""
    replace_html_entities(input_text::AbstractString,
                    remove_illegal=true) => (entities_replaced_text::AbstractString)

Removes entities from text by converting them to their corresponding unicode character.
`input_text::AbstractString` The string on which HTML entities need to be replaced
`remove_illegal::Bool` If `true`, entities that can't be converted are
removed. Otherwise, entities that can't be converted are kept "as
is".
Returns `entities_replaced_text::AbstractString`
"""
function replace_html_entities(input_text::AbstractString; remove_illegal=true)

    function convert_entity(matched_text)
        # HTML entity can be named or encoded in Decimal/Hex form
        # - Named_entity : "&Delta;" => "Δ",
        # - Decimal : "&#916;" => "Δ",
        # - Hex : ""&#x394;" => "Δ",
        #
        # However for bytes (hex) 80-9f are interpreted in Windows-1252
        is_numeric_encoded, is_hex_encoded, entity_text = match(HTML_ENTITIES_REGEX,
                                                matched_text).captures
        number = -1

        if isempty(is_numeric_encoded)
            return lookupname(HTML_Entities.default, entity_text)
        else
            if isempty(is_hex_encoded)
                is_numeric = all(isdigit, entity_text)
                if is_numeric
                    number = parse(Int, entity_text, base=10)
                end
            else
                base_16_letters = ('a', 'b', 'c', 'd', 'e', 'f')
                is_base_16 = all(entity_text) do i
                    isdigit(i) || i in base_16_letters
                end
                if is_base_16
                    number = parse(Int, entity_text, base=16)
                end
            end

            # Numeric character references in the 80-9F range are typically
            # interpreted by browsers as representing the characters mapped
            # to bytes 80-9F in the Windows-1252 encoding. For more info
            # see: https://en.wikipedia.org/wiki/ISO/IEC_8859-1#Similar_character_sets

            if number >= 0
                if 0x80 <= number <= 0x9F
                    if number ∉ (129, 141, 143, 144, 157)
                        return decode([UInt8(number)], "WINDOWS-1252")
                    end
                elseif Unicode.isassigned(number)
                        return Char(number)
                end
            end
        end

        if remove_illegal
            return ""
        else
            return matched_text
        end
    end

    entities_replaced_text = replace(input_text, HTML_ENTITIES_REGEX => convert_entity)
    return entities_replaced_text
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

    # Fix HTML Character entities
    source = replace_html_entities(source)
    # Remove username handles
    if strip_handle
        source = replace(source, HANDLES_REGEX => " ")
    end
    # Reduce Lengthening
    if reduce_len
        source = replace(source, r"(.)\1{2,}" => s"\1\1\1")
    end
    # Shorten some sequences of characters
    safe_text = replace(source, r"""([^a-zA-Z0-9])\1{3,}""" => s"\1\1\1")
    # Tokenize
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
