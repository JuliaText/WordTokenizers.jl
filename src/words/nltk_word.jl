


const nltk_atoms = collect.(["--", "...", "``", "\$"])
const nltk_suffixes = collect.(["'ll", "'re", "'ve", "n't", "'s", "'m", "'d"])
const nltk_splits = [("cannot", 3), ("gimme", 3), ("lemme", 3), ("mor'n", 3),
                     ("d'ye", 3), ("gonna", 3), ("gotta", 3), ("wanna", 3),
                     ("'tis", 2), ("'twas", 2)]

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
    splits(ts, nltk_splits) ||
    number(ts) ||
    character(ts)
    !isdone(ts) && closingquote(ts)
  end
  stop && push!(ts.tokens, ".")
  return ts.tokens
end

