# WordTokenisers
Some basic tokenizers for Natural Language Processing:

# Sentence Splitters
We currently only have one sentence splitter.
 - **Rule Based Sentence Spitter:** (`rulebased_split_sentences`), uses a rule that periods, question marks, and exclamation marks, followed by white-space end sentences. With a large list of exceptions.

`split_sentences` is exported as an alias for the most useful sentence splitter currently implemented.
 (Which ATM is the only sentence splitter: `rulebased_split_sentences`)


# (Word) Tokenizers
The word tokenizers basically assume sentence splitting has already been done.

 - **Poorman's tokenizer:** (`poormans_tokenize`) Deletes all punctuation, and splits on spaces. (In some ways worse than just using `split`)
 - **Punctuation space tokenize:** (`punctuation_space_tokenize`) Marginally improved version of the poorman's tokeniser, only deletes punctuation occurring outside words.

 - **Penn Tokeniser:** (`penn_tokenize`) This is Robert MacIntyre's orginal tokeniser used for the Penn Treebank. Splits contractions.
 - **Improved Penn Tokeniser:** (`improved_penn_tokenize`) NLTK's improved Penn Treebank Tokenizer. Very similar to the original, some improvements on punctuation and contractions. This matches to NLTK's `nltk.tokenize.TreeBankWordTokenizer.tokenize`
 - **NLTK Word tokenizer:** (`nltk_word_tokenize`) NLTK's even more improved version of the Penn Tokenizer. This version has better unicode handling and some other changes. This matches to the most commonly used `nltk.word_tokenize`, minus the sentence tokenizing step.

  (To me it seems like a weird historical thing that NLTK has 2 successive variation on improving the Penn tokenizer, but for now I am matching it and having both)


Also exported is `tokenize` which is an alias for the most useful tokeniser currently implemented.
(Which ATM is `nltk_word_tokenize`)

# Example

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
```

```julia
julia> text = "The leatherback sea turtle is the largest, measuring six or seven feet (2 m) in length at maturity, and three to five feet (1 to 1.5 m) in width, weighing up to 2000 pounds (about 900 kg). Most other species are smaller, being two to four feet in length (0.5 to 1 m) and proportionally less wide. The Flatback turtle is found solely on the northerncoast of Australia.";

julia> split_sentences(text)
3-element Array{SubString{String},1}:
 "The leatherback sea turtle is the largest, measuring six or seven feet (2 m) in length at maturity, and three to five feet (1 to 1.5 m) in width, weighing up to 2000 pounds (about900 kg). "
 "Most other species are smaller, being two to four feet in length (0.5 to 1 m) and proportionally less wide. "
 "The Flatback turtle is found solely on the northern coast of Australia."

julia> tokenize.(split_sentences(text))
3-element Array{Array{SubString{String},1},1}:
 SubString{String}["The", "leatherback", "sea", "turtle", "is", "the", "largest", ",", "measuring", "six"  …  "up", "to", "2000", "pounds", "(", "about", "900", "kg", ")", "."]
 SubString{String}["Most", "other", "species", "are", "smaller", ",", "being", "two", "to", "four"  …  "0.5", "to", "1", "m", ")", "and", "proportionally", "less", "wide", "."]
 SubString{String}["The", "Flatback", "turtle", "is", "found", "solely", "on", "the", "northern", "coast", "of", "Australia", "."]
```


## Experimental API
I am trying out an experimental API
where these are added as dispatches to Base.split.

So   
`split(foo, Words` is the same as `tokenize(foo)`,  
and  
`split(foo, Sentences)` is the same as `split_sentences(foo)`.
