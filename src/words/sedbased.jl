"""
    generate_tokenizer_from_sed(sed_script_path)

This returns Julia code, that is the translation of a simple sed script
for tokenizing.
This doesn't fully cover all the functionality of sed,
but it covers enough for many purposes.
"""
function generate_tokenizer_from_sed(sed_script, extended=false)::Expr
    code = quote
        ss = input
    end
    for src_line in eachline(sed_script)
        src_line=strip(src_line)
        length(src_line)==0 && continue # skip blanks
        src_line[1]=='#' && continue # skip comments

        #sed lines are `<op><sep><pattern><sep><replacement><sep>flags`
        seperator = src_line[2]
        op, pattern, replacement, flags = split(src_line, seperator)
        @assert(op=="s") #substitute
        @assert(flags=="g" || flags=="", "Unsupported flags: $flags") #substitute

        if extended
        else
            # Normal sed uses `\(` instead of `(` for grouping
            pattern=replace(pattern, raw"\("=> "(")
            pattern=replace(pattern, raw"\)"=> ")")

            #sed accepts `&` as whole match
            replacement=replace(replacement, "&" => raw"\0")
        end


        push!(code.args, :(
            ss=replace(ss,
                       Regex($pattern) =>
                       Base.SubstitutionString($replacement))
        ))
    end
    push!(code.args, :(split(ss)))
    code
end


"""
    penn_tokenize(input::AbstractString)

"... to produce Penn Treebank tokenization on arbitrary raw text.
Yeah, sure" quote Robert MacIntyre


Tokenization does a number of things like seperate out contractions:
"shouldn't" becomes ["should", "n't"]
Most other punctuation becomes &'s.
Exception is periods which are not touched.
The input should be a single sentence;
but it will likely be relatively fine if it isn't.
Depends exactly what you want it for.

This is a direct (automatic) translation of the original sed script.

If you want to mess with exactly what it does it is actually really easy.
copy the penn.sed file from this repo, modify it to your hearts content.
There are some lines you can uncomment out.
You can generate a new tokenizer using:

```
@generated function custom_tokenizer(input::AbstractString)
    generate_tokenizer_from_sed(joinpath(@__DIR__, "custom.sed"))
end
```
"""
@generated function penn_tokenize(input::AbstractString)
    script = joinpath(@__DIR__, "penn.sed")
    generate_tokenizer_from_sed(script, false)
end



"""
    improved_penn_tokenize(input::AbstractString)

The Improved Penn Treebank tokenizer.
This is a port of NLTK's modified Penn Tokenizer.
It has a bundle of minor changes,
that I don't think are actually documented anywhere.
But things like `cannot cannot` become `can not can not`
where as the original would produce `can not cannot`.

The tokenizer still seperates out contractions:
"shouldn't" becomes ["should", "n't"]

The input should be a single sentence;
but again it will likely be relatively fine if it isn't.
Depends exactly what you want it for.

This matches NLTK's `nltk.tokenize.TreeBankWordTokenizer.tokenize`
"""
@generated function improved_penn_tokenize(input::AbstractString)
    script = joinpath(@__DIR__, "improved_penn.sed")
    generate_tokenizer_from_sed(script, true)
end



"""
    nltk_word_tokenize(input::AbstractString)

NLTK's word tokenizer.
It is an extention on the Punctuation Preserving Penn Treebank tokenizer,
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
@generated function nltk_word_tokenize(input::AbstractString)
    script = joinpath(@__DIR__, "nltk_word.sed")
    generate_tokenizer_from_sed(script, true)
end
