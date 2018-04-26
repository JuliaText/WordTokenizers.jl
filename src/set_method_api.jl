
"""
    set_tokenizer(fun)

Call this to set the default tokenizer to invoke the passed in function `fun`
It will be used by `tokenize`.
Calling this will trigger recompilation of any functions that use `tokenize`.

Calling `set_tokenizer`  will give method overwritten warnings. They are expected, be worried if they do not occur
"""
function set_tokenizer(fun)
    @eval tokenize(str::AbstractString) = $(fun)(str)
end

"""
    set_sentence_splitter(fun)

Call this to set the default sentence splitter to invoke the passed in function `fun`
It will be used by `split_sentences`.
Calling this will trigger recompilation of any functions that use `split_sentences`.

Calling `set_sentence_splitter`  will give method overwritten warnings. They are expected, be worried if they do not occur
"""
function set_sentence_splitter(fun)
    @eval split_sentences(str::AbstractString) = $(fun)(str)
end


set_tokenizer(nltk_word_tokenize)
set_sentence_splitter(rulebased_split_sentences)
