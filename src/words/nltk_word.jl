const nltk_atoms = collect.(["--", "...", "``", "\$"])
const nltk_suffixes = collect.(["'ll", "'re", "'ve", "n't", "'s", "'m", "'d"])
const nltk_splits = [
    "cannot"=>("can", "not"),
    "gimme"=>("gim", "me"),
    "lemme"=>("lem", "me"),
    "mor'n"=>("mor", "'n"),
    "d'ye"=>("d'n", "e"),
    "gonna"=>("gon","na"),
    "gotta"=>("got","ta"),
    "wanna"=>("wan","na"),
    "'tis"=>("'t", "is"),
    "'twas"=>("'t", "was"),
]

"""
    nltk_word_tokenize(input)

NLTK's word tokenizer.
It is an extension on the Punctuation Preserving Penn Treebank tokenizer,
mostly to better handle unicode.

Punctuation is still preserved as its own token.
This includes periods which will be stripped from words.

The tokenizer still seperates out contractions:
"shouldn't" becomes ["should", "n't"]

The input should be a single sentence;
but again it will likely be relatively fine if it isn't.
Depends exactly what you want it for.

This matches to the most commonly used `nltk.word_tokenize`, minus the sentence tokenizing step.
"""
function nltk_word_tokenize(input)
    ts = TokenBuffer(input)
    isempty(input) && return ts.tokens
    stop = ts.input[end] == '.' # `.` is usually absorbed into tokens (`Dr.`)
                              # Treat the last `.` specially.
    stop && pop!(ts.input)
    while !isdone(ts)
        spaces(ts) && continue
        openquote(ts) ||
        suffixes(ts, nltk_suffixes) ||
        atoms(ts, nltk_atoms) ||
        replaces(ts, nltk_splits) ||
        number(ts) ||
        character(ts)
        !isdone(ts) && closingquote(ts)
    end
    stop && push!(ts.tokens, ".")
    return ts.tokens
end
