EMOTICONS_REGEX = r"""(?x)
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


URLS = r"""(?x)
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


PHONE_NUMBERS = r"""(?x)
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


HTML_TAGS = r"""<[^>\s]+>"""
ASCII_ARROWS = r"""[\-]+>|<[\-]+"""
TWITTER_USERNAME = r"""(?:@[\w_]+)"""
TWITTER_HASHTAGS = r"""(?:\#+[\w_]+[\w\'_\-]*[\w_]+)"""
EMAIL_ADDRESSES = r"""[\w.+-]+@[\w-]+\.(?:[\w-]\.?)+[\w-]"""
WORDS_WITH_APOSTROPHE_DASHES = r"""(?:[^\W\d_](?:[^\W\d_]|['\-_])+[^\W\d_])"""
NUMBERS_FRACTIONS_DECIMALS = r"""(?:[+\-]?\d+[,/.:-]\d+[+\-]?)"""
ELLIPSIS_DOTS = r"""(?:\.(?:\s*\.){1,})"""
WORDS_WITHOUT_APOSTROPHE_DASHES = r"""(?:[\w_]+)"""



# Core tokenizing regex
WORD_REGEX = Regex("(?i:" * join([URLS.pattern
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
HANG_REGEX = r"""([^a-zA-Z0-9])\1{3,}"""

# Regex for replacing HTML_Entities
HTML_ENTITIES_REGEX = r"""&(#?(x?))([^&;\s]+);"""

HANDLES_REGEX = r"""(?x)
                (?<![A-Za-z0-9_!@#\$%&*])@(([A-Za-z0-9_]){20}(?!@))
                |
                (?<![A-Za-z0-9_!@#\$%&*])@(([A-Za-z0-9_]){1,19})(?![A-Za-z0-9_]*@)
                """



function replace_html_entities(input_text::AbstractString, remove_illegal=true)

    function convert_entity(matched_text)

        groups = match(HTML_ENTITIES_REGEX, matched_text).captures
        entity_body = groups[3]
        local number::Number = 0
        if isempty(groups[1])
            return(lookupname(HTML_Entities.default, entity_body))
        else
            if isempty(groups[2])
                is_numeric = true
                for i in entity_body
                    if !isdigit(i)
                        is_numeric = false
                        break
                    end
                end
                if is_numeric
                    number = parse(Int, entity_body, base=10)
                end
            else
                is_base_16 = true
                allowed_letters = ['a', 'b', 'c', 'd', 'e', 'f']
                for i in entity_body
                    if !(isdigit(i) || i in allowed_letters)
                        is_base_16 = false
                        break
                    end
                end
                if is_base_16
                    number = parse(Int, entity_body, base=16)
                end
            end

            # Numeric character references in the 80-9F range are typically
            # interpreted by browsers as representing the characters mapped
            # to bytes 80-9F in the Windows-1252 encoding. For more info
            # see: http://en.wikipedia.org/wiki/Character_encodings_in_HTML

            if 0x80 <= number <= 0x9F
                if !(number in [129 141 143 144 157])
                    return decode([UInt8(number)], "WINDOWS-1252")
                end
            else
                if Unicode.isassigned(number)
                    return (Char(number))
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
end
