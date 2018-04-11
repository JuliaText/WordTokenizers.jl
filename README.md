# WordTokenisers
Some basic tokenizers for Natural Language Processing:

 - **Poormans tokeniser:** (`poormans_tokenize`) Deletes all punctuation, and splits on spaces. (In some ways worse than just using `split`)
 - **Punctuation space tokenize:** (`punctuation_space_tokenize`) Marginally improved version of the poorman's tokeniser, only deletes punctuation occuring outside words.

 - **Penn Tokeniser:** (`penn_tokenize`) The Robert MacIntyre's orginal tokeniser used for the Penn Treebank. Splits contractions.
 - **Improved Penn Tokeniser:** (`improved_penn_tokenize`) NLTK's improved Penn Treebank Tokenizer. Very similar to the original, some improvements on punctuation and contractions. This matches to NLTK's `nltk.tokenize.TreeBankWordTokenizer.tokenize`
 - **NLTK Word tokenizer:** (`nltk_word_tokenize`) NLTK's even more improved version of the Penn Tokenizer. This version has better unicode handling and some other changes. This matches to the most commonly used `nltk.word_tokenize`, minus the sentence tokenizing step.

  (To me it seems like a weird historical thing that NLTK has 2 successive variation on improving the Penn tokenizer, but for now I am matching it and having both)


Also exported is `tokenize` which is an alias for the most useful tokeniser currently implemented.
(Which ATM is `nltk_word_tokenize`)

```
julia> tokenize("The package's tokenisers range from simple (e.g. poorman's), to complex (e.g. Penn).") |> repr|>print
20-element Array{SubString{String},1}:
 "The"
 "package"
 "'s"
 "tokenisers"
 "range"
 "from"
 "simple"
 "("
 "e.g."
 "poorman"
 "'s"
 ")"
 ","
 "to"
 "complex"
 "("
 "e.g."
 "Penn"
 ")"
 "."
````
