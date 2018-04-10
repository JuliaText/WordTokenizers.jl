# WordTokenisers
Some basic tokenizers for Natural Language Processing:

 - **Poormans tokeniser:** (`poormans_tokenize`) Deletes all punctuation, and splits on spaces. (In some ways worse than just using `split`)
 - **Punctuation space tokenize:** (`punctuation_space_tokenize`) Marginally improved version of the poorman's tokeniser, only deletes punctuation occuring outside words.
 - **Penn Tokeniser:** (`penn_tokenize`) The Robert MacIntyre's orginal tokeniser used for the Penn Treebank. Splits contractions, converts all punctuation to `&`
 - **Improved Penn Tokeniser:** (`improved_penn_tokenize`) NLTK's improved Penn Tokenizer. Very similar to the original, except preserves all punctuation.
 
 
Also exported is `tokenize` which is an alias for the most useful tokeniser currently implemented.
(Which ATM is `improved_penn_tokenize`)

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
