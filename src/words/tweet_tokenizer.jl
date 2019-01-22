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
