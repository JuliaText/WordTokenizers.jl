# WordTokenizers
Some basic tokenizers for Natural Language Processing:

The normal way to used this package is to call
`tokenize(str)` to split up a string into words;
or `split_sentences(str)` to split up a string into sentences.
Maybe even `tokenize.(split_sentences(str))` to do both.

`tokenize` and `split_sentences`, are configurable functions
that call one of the tokenizers or sentence splitters defined below.
They have sensible defaults set,
but you can override the method used by calling
`set_tokenizer(func)` or `set_sentence_splitter(func)` passing in your preferred
function `func` from the list below (or from else where)
Configuring them this way will throw up a method overwritten warning, and trigger recompilation of any methods that use them.

This means if you are using a package that uses WordTokenizers.jl to do tokenization/sentence splitting via the default methods;
changing the tokenizer/splitter will change the behavior of that package.
This is a feature of [CorpusLoaders.jl](https://github.com/JuliaText/CorpusLoaders.jl).
If as a package author you don't want to allow the user to change the tokenizer in this way, you should use the tokenizer you want explicitly, rather than using the  `tokenize` method.




### Example Setting Tokenizer  (Revtok.jl)
You might like to, for example use [Revtok.jl's tokenizer](https://github.com/jekbradbury/Revtok.jl).
We do not include Revtok in this package, because making use of it with-in WordTokenizers.jl is trival.
Just `import Revtok; set_tokenizer(Revtok.tokenize)`.


Full example:

```
julia> using WordTokenizers

julia> text = "I cannot stand when they say \"Enough is enough.\"";

julia> tokenize(text) |> print # Default tokenizer
SubString{String}["I", "can", "not", "stand", "when", "they", "say", "``", "Enough", "is", "enough", ".", "''"]

julia> import Revtok

julia> set_tokenizer(Revtok.tokenize)
WARNING: Method definition tokenize(AbstractString) in module WordTokenizers overwritten
tokenize (generic function with 1 method)


julia> tokenize(text) |> print # Revtok's tokenizer
String[" I ", " cannot ", " stand ", " when ", " they ", " say ", " \"", " Enough ", " is ", " enough ", ".\" "]
```



# (Word) Tokenizers
The word tokenizers basically assume sentence splitting has already been done.

 - **Poorman's tokenizer:** (`poormans_tokenize`) Deletes all punctuation, and splits on spaces. (In some ways worse than just using `split`)
 - **Punctuation space tokenize:** (`punctuation_space_tokenize`) Marginally improved version of the poorman's tokenizer, only deletes punctuation occurring outside words.

 - **Penn Tokenizer:** (`penn_tokenize`) This is Robert MacIntyre's orginal tokenizer used for the Penn Treebank. Splits contractions.
 - **Improved Penn Tokenizer:** (`improved_penn_tokenize`) NLTK's improved Penn Treebank Tokenizer. Very similar to the original, some improvements on punctuation and contractions. This matches to NLTK's `nltk.tokenize.TreeBankWordTokenizer.tokenize`
 - **NLTK Word tokenizer:** (`nltk_word_tokenize`) NLTK's even more improved version of the Penn Tokenizer. This version has better unicode handling and some other changes. This matches to the most commonly used `nltk.word_tokenize`, minus the sentence tokenizing step. **(default tokenizer)**

- **Reversible Tokenizer:** (`rev_tokenizer` and `rev_detokenizer`) This tokenizer splits on punctuations, space amd special symbols. The generated tokens can be de-tokenized by using the `rev_detokenizer` function into the state before tokenization. 


  (To me it seems like a weird historical thing that NLTK has 2 successive variation on improving the Penn tokenizer, but for now I am matching it and having both.  See [[NLTK#2005]](https://github.com/nltk/nltk/issues/2005))


# Sentence Splitters
We currently only have one sentence splitter.
 - **Rule Based Sentence Spitter:** (`rulebased_split_sentences`), uses a rule that periods, question marks, and exclamation marks, followed by white-space end sentences. With a large list of exceptions.

`split_sentences` is exported as an alias for the most useful sentence splitter currently implemented.
 (Which ATM is the only sentence splitter: `rulebased_split_sentences`) **(default sentence_splitter)**


# Example

```julia
julia> tokenize("The package's tokenizers range from simple (e.g. poorman's), to complex (e.g. Penn).") |> print
SubString{String}["The", "package", "'s", "tokenizers", "range", "from", "simple", "(", "e.g.", "poorman", "'s", ")",",", "to", "complex", "(", "e.g.", "Penn", ")", "."]
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
where these are added as dispatches to `Base.split`

So   
`split(foo, Words)` is the same as `tokenize(foo)`,  
and  
`split(foo, Sentences)` is the same as `split_sentences(foo)`.
