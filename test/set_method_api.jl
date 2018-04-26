using Base.Test
using WordTokenizers

set_tokenizer(nltk_word_tokenize)
@test tokenize("it cannot cannot be today") == ["it", "can", "not", "can", "not", "be", "today"]

set_tokenizer(penn_tokenize)
@test tokenize("it cannot cannot be today") ==  ["it", "can", "not", "cannot", "be", "today"]

set_tokenizer(nltk_word_tokenize)
@test tokenize("it cannot cannot be today") == ["it", "can", "not", "can", "not", "be", "today"]
