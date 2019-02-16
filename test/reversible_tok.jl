using Test
using WordTokenizers

str = "Some of 100,000 households (usually, a minority) ate breakfast."
tokenized = ["Some", "of", "100", "~,~", "000", "households", "(~", "usually", "~,", "a", "minority", "~)", "ate", "breakfast", "~."]

@test tokenized == String.(rev_tokenizer(str))

@test str == rev_detokenizer(tokenized)



