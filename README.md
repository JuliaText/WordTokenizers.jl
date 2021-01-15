# WordTokenizers
[![ColPrac: Contributor's Guide on Collaborative Practices for Community Packages](https://img.shields.io/badge/ColPrac-Contributor's%20Guide-blueviolet)](https://github.com/SciML/ColPrac)
[![GitHub release](https://img.shields.io/github/release/JuliaText/WordTokenizers.jl.svg)](https://github.com/JuliaText/WordTokenizers.jl/releases/)
[![Build Status](https://travis-ci.org/JuliaText/WordTokenizers.jl.svg?branch=master)](https://travis-ci.org/JuliaText/WordTokenizers.jl)
[![codecov](https://codecov.io/gh/JuliaText/WordTokenizers.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/JuliaText/WordTokenizers.jl)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/JuliaText/WordTokenizers.jl?branch=master&svg=true)](https://ci.appveyor.com/project/oxinabox/wordtokenizers-jl/history)
[![HitCount](http://hits.dwyl.io/JuliaText/WordTokenizers.svg)](http://hits.dwyl.io/JuliaText/WordTokenizers)

Some basic tokenizers for Natural Language Processing.

### Installation:
As per standard [Julia package installation](https://julialang.github.io/Pkg.jl/dev/managing-packages/#Adding-registered-packages-1):   
```
pkg> add WordTokenizers
```

### Usage

The normal way to use this package is to call
`tokenize(str)` to split up a string into words
or `split_sentences(str)` to split up a string into sentences.
Maybe even `tokenize.(split_sentences(str))` to do both.

`tokenize` and `split_sentences` are configurable functions
that call one of the tokenizers or sentence splitters defined below.
They have sensible defaults set,
but you can override the method used by calling
`set_tokenizer(func)` or `set_sentence_splitter(func)` passing in your preferred
function `func` from the list below (or from elsewhere)
Configuring them this way will throw up a method overwritten warning, and trigger recompilation of any methods that use them.

This means if you are using a package that uses WordTokenizers.jl to do tokenization/sentence splitting via the default methods,
changing the tokenizer/splitter will change the behavior of that package.
This is a feature of [CorpusLoaders.jl](https://github.com/JuliaText/CorpusLoaders.jl).
If as a package author you don't want to allow the user to change the tokenizer in this way, you should use the tokenizer you want explicitly, rather than using the  `tokenize` method.




### Example Setting Tokenizer (TinySegmenter.jl)
You might like to, for example use [TinySegmenter.jl's tokenizer](https://github.com/JuliaStrings/TinySegmenter.jl) for Japanese text.
We do not include TinySegmenter in this package, because making use of it within WordTokenizers.jl is trivial.
Just `import TinySegmenter; set_tokenizer(TinySegmenter.tokenize)`.


Full example:

```julia
julia> using WordTokenizers

julia> text = "私の名前は中野です";

julia> tokenize(text) |> print # Default tokenizer
["私の名前は中野です"]

julia> import TinySegmenter

julia> set_tokenizer(TinySegmenter.tokenize)

julia> tokenize(text) |> print # TinySegmenter's tokenizer
SubString{String}["私", "の", "名前", "は", "中野", "です"]
```



# (Word) Tokenizers
The word tokenizers basically assume sentence splitting has already been done.

 - **Poorman's tokenizer:** (`poormans_tokenize`) Deletes all punctuation, and splits on spaces. (In some ways worse than just using `split`)
 - **Punctuation space tokenize:** (`punctuation_space_tokenize`) Marginally improved version of the poorman's tokenizer, only deletes punctuation occurring outside words.

 - **Penn Tokenizer:** (`penn_tokenize`) This is Robert MacIntyre's original tokenizer used for the Penn Treebank. Splits contractions.
 - **Improved Penn Tokenizer:** (`improved_penn_tokenize`) NLTK's improved Penn Treebank Tokenizer. Very similar to the original, some improvements on punctuation and contractions. This matches to NLTK's `nltk.tokenize.TreeBankWordTokenizer.tokenize`.
 - **NLTK Word tokenizer:** (`nltk_word_tokenize`) NLTK's even more improved version of the Penn Tokenizer. This version has better Unicode handling and some other changes. This matches to the most commonly used `nltk.word_tokenize`, minus the sentence tokenizing step.

  (To me it seems like a weird historical thing that NLTK has 2 successive variations on improving the Penn tokenizer, but for now, I am matching it and having both.  See [[NLTK#2005]](https://github.com/nltk/nltk/issues/2005).)

 - **Reversible Tokenizer:** (`rev_tokenize` and `rev_detokenize`) This tokenizer splits on punctuations, space and special symbols. The generated tokens can be de-tokenized by using the `rev_detokenizer` function into the state before tokenization.
 - **TokTok Tokenizer:** (`toktok_tokenize`) This tokenizer is a simple, general tokenizer, where the input has one sentence per line; thus only final period is tokenized. This is an enhanced version of the [original toktok Tokenizer](https://github.com/jonsafari/tok-tok). It has been tested on and gives reasonably good results for English, Persian, Russian, Czech, French, German, Vietnamese, Tajik, and a few others. **(default tokenizer)**
 - **Tweet Tokenizer:** (`tweet_tokenizer`) NLTK's casual tokenizer for that is solely designed for tweets. Apart from being twitter specific, this tokenizer has good handling for emoticons and other web aspects like support for HTML Entities. This closely matches NLTK's `nltk.tokenize.TweetTokenizer`


# Sentence Splitters
We currently only have one sentence splitter.
 - **Rule-Based Sentence Spitter:** (`rulebased_split_sentences`), uses a rule that periods, question marks, and exclamation marks, followed by white-space end sentences. With a large list of exceptions.

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
where these are added as dispatches to `Base.split`.

So   
`split(foo, Words)` is the same as `tokenize(foo)`,  
and  
`split(foo, Sentences)` is the same as `split_sentences(foo)`.

## Using TokenBuffer API for Custom Tokenizers
We offer a `TokenBuffer` API and supporting utility lexers
for high-speed tokenization.

#### Writing your own TokenBuffer tokenizers

`TokenBuffer` turns a string into a readable stream, used for building tokenizers.
Utility lexers such as `spaces` and `<span class="x x-first x-last">number</span>` read characters from the
stream and into an array of tokens.

Lexers return `true` or `false` to indicate whether they matched
in the input stream. They can, therefore, be combined easily, e.g.

    spacesornumber(ts) = spaces(ts) || number(ts)

either skips whitespace or parses a number token, if possible.

The simplest useful tokenizer splits on spaces.

    using WordTokenizers: TokenBuffer, isdone, spaces, character

    function tokenise(input)
        ts = TokenBuffer(input)
        while !isdone(ts)
            spaces(ts) || character(ts)
        end
        return ts.tokens
    end

    tokenise("foo bar baz") # ["foo", "bar", "baz"]

Many prewritten components for building custom tokenizers
can be found in `src/words/fast.jl` and `src/words/tweet_tokenizer.jl`
These components can be mixed and matched to create more complex tokenizers.

Here is a more complex example.

```julia
julia> using WordTokenizers: TokenBuffer, isdone, character, spaces # Present in fast.jl

julia> using WordTokenizers: nltk_url1, nltk_url2, nltk_phonenumbers # Present in tweet_tokenizer.jl

julia> function tokeinze(input)
           urls(ts) = nltk_url1(ts) || nltk_url2(ts)

           ts = TokenBuffer(input)
           while !isdone(ts)
               spaces(ts) && continue
               urls(ts) ||
               nltk_phonenumbers(ts) ||
               character(ts)
           end
           return ts.tokens
       end
tokeinze (generic function with 1 method)

julia> tokeinze("A url https://github.com/JuliaText/WordTokenizers.jl/ and phonenumber +0 (987) - 2344321")
6-element Array{String,1}:
 "A"
 "url"
 "https://github.com/JuliaText/WordTokenizers.jl/" # URL detected.
 "and"
 "phonenumber"
 "+0 (987) - 2344321" # Phone number detected.
```

#### Tips for writing custom tokenizers and your own TokenBuffer Lexer

1. The order in which the lexers are written needs to be taken care of in some cases-

For example: `987-654-3210` matches as a phone number
as well as numbers, but `number` will only match up to `987`
and split after it.

```julia
julia> using WordTokenizers: TokenBuffer, isdone, character, spaces, nltk_phonenumbers, number

julia> order1(ts) = number(ts) || nltk_phonenumbers(ts)
order1 (generic function with 1 method)

julia> order2(ts) = nltk_phonenumbers(ts) || number(ts)
order2 (generic function with 1 method)

julia> function tokenize1(input)
           ts = TokenBuffer(input)
           while !isdone(ts)
               order1(ts) ||
               character(ts)
           end
           return ts.tokens
       end
tokenize1 (generic function with 1 method)

julia> function tokenize2(input)
           ts = TokenBuffer(input)
           while !isdone(ts)
               order2(ts) ||
               character(ts)
           end
           return ts.tokens
       end
tokenize2 (generic function with 1 method)

julia> tokenize1("987-654-3210") # number(ts) || nltk_phonenumbers(ts)
5-element Array{String,1}:
 "987"
 "-"
 "654"
 "-"
 "3210"

julia> tokenize2("987-654-3210") # nltk_phonenumbers(ts) || number(ts)
1-element Array{String,1}:
 "987-654-3210"
```

2. BoundsError and errors while handling edge cases are most common
and need to be taken of while writing the TokenBuffer lexers.

3. For some TokenBuffer `ts`, use `flush!(ts)`
over `push!(ts.tokens, input[i:j])`, to make sure that characters
in the Buffer (i.e. ts.Buffer) also gets flushed out as separate tokens.

```julia
julia> using WordTokenizers: TokenBuffer, flush!, spaces, character, isdone

julia> function tokenize(input)
           ts = TokenBuffer(input)

           while !isdone(ts)
               spaces(ts) && continue
               my_pattern(ts) ||
               character(ts)
           end
           return ts.tokens
       end

julia> function my_pattern(ts) # Matches the pattern for 2 continuous `_`
           ts.idx + 1 <= length(ts.input) || return false

           if ts[ts.idx] == '_' && ts[ts.idx + 1] == '_'
               flush!(ts, "__") # Using flush!
               ts.idx += 2
               return true
           end

           return false
       end
my_pattern (generic function with 1 method)

julia> tokenize("hi__hello")
3-element Array{String,1}:
 "hi"
 "__"
 "hello"

julia> function my_pattern(ts) # Matches the pattern for 2 continuous `_`
           ts.idx + 1 <= length(ts.input) || return false

           if ts[ts.idx] == '_' && ts[ts.idx + 1] == '_'
               push!(ts.tokens, "__") # Without using flush!
               ts.idx += 2
               return true
           end

           return false
       end
my_pattern (generic function with 1 method)

julia> tokenize("hi__hello")
2-element Array{String,1}:
 "__"
 "hihello"
```
# Statistical Tokenizer 

**Sentencepiece Unigram Encoder** is basically  the Sentencepiece processor's re-implementation in julia. It can used vocab file generated by sentencepiece library containing both vocab and log probability.

For more detail about implementation refer the blog post [here](https://tejasvaidhyadev.github.io/blog/Sentencepiece)

**Note** :

- SentencePiece escapes the whitespace with a meta symbol "▁" (U+2581).


### Pretrained 

Wordtokenizer provides pretrained vocab file of Albert (both version-1 and version-2) 

```julia
julia> subtypes(PretrainedTokenizer)
2-element Array{Any,1}:
 ALBERT_V1
 ALBERT_V2

julia> tokenizerfiles(ALBERT_V1)
4-element Array{String,1}:
 "albert_base_v1_30k-clean.vocab"   
 "albert_large_v1_30k-clean.vocab"  
 "albert_xlarge_v1_30k-clean.vocab" 
 "albert_xxlarge_v1_30k-clean.vocab"
```

`DataDeps` will handle all the downloading part for us.  You can also create an issue or PR for other pretrained models or directly load by providing path in `load` function

```julia
julia> spm = load(Albert_Version1) #loading Default Albert-base vocab in Sentencepiece
WordTokenizers.SentencePieceModel(Dict("▁shots"=>(-11.2373, 7281),"▁ordered"=>(-9.84973, 1906),"dev"=>(-12.0915, 14439),"▁silv"=>(-12.6564, 21065),"▁doubtful"=>(-12.7799, 22569),"▁without"=>(-8.34227, 367),"▁pol"=>(-10.7694, 4828),"chem"=>(-12.3713, 17661),"▁1947,"=>(-11.7544, 11199),"▁disrespect"=>(-13.13, 26682)…), 2)

julia> tk = tokenizer(spm, "i love the julia language") #or tk = spm("i love the julia language")
4-element Array{String,1}:
 "▁i"       
 "▁love"
 "▁the"    
 "▁julia"   
 "▁language"

julia> subword = tokenizer(spm, "unfriendly")
2-element Array{String,1}:
 "▁un"
 "friendly"

julia> para = spm("Julia is a high-level, high-performance dynamic language for technical computing")
17-element Array{String,1}:
 "▁"          
 "J"          
 "ulia"       
 "▁is"        
 "▁a"         
 "▁high"      
 "-"          
 "level"      
 ","          
 "▁high"      
 "-"          
 "performance"
 "▁dynamic"   
 "▁language"  
 "▁for"       
 "▁technical" 
 "▁computing" 
```

Indices is usually used for deep learning models.
Index of special tokens in ALBERT are given below:

1 &#8658; [PAD]  
2 &#8658; [UNK]  
3 &#8658; [CLS]  
4 &#8658; [SEP]  
5 &#8658; [MASK]  


```julia
julia> ids_from_tokens(spm, tk)
4-element Array{Int64,1}:
   32
  340
   15
 5424
  817
#we can also get sentences back from tokens
julia> sentence_from_tokens(tk)
 "i love the julia language"

julia> sentence_from_token(subword)
 "unfriendly"

julia> sentence_from_tokens(para)
 "Julia is a high-level, high-performance dynamic language for technical computing"
```

## Contributing
Contributions, in the form of bug-reports, pull-requests, additional documentation are encouraged.
They can be made to the GitHub repository.

We follow the [ColPrac guide for collaborative practices](https://github.com/SciML/ColPrac).
New contributor should make sure to read that guide.

**All contributions and communications should abide by the [Julia Community Standards](https://julialang.org/community/standards/).**

Software contributions should follow the prevailing style within the code-base.
If your pull request (or issues) are not getting responses within a few days do not hesitate to "bump" them,
by posting a comment such as "Any update on the status of this?".
Sometimes GitHub notifications get lost.

## Support

Feel free to ask for help on the [Julia Discourse forum](https://discourse.julialang.org/),
or in the `#natural-language` channel on julia-slack. (Which you can [join here](https://slackinvite.julialang.org/)).
You can also raise issues in this repository to request improvements to the documentation.
