using Test
using WordTokenizers

str = "The quick brown fox jumped over the lazy dog"                
tokenized = ["The", "quick", "brown", "fox", "jumped", "over", "the", "lazy", "dog"]

@test tokenized == String.(rev_tokenizer(str))           # testing defualt functioning of rev_tokenizer
@test str == rev_detokenizer(tokenized)                  # testing defualt functioning of rev_detokenizer


str = "Some of 100,000 households (usually, a minority) ate breakfast."
tokenized = ["Some", "of", "100", "⇆,⇆", "000", "households", "(⇆", "usually", "⇆,", "a", "minority", "⇆)", "ate", "breakfast", "⇆."]

@test tokenized == String.(rev_tokenizer(str))         # multi-byte character tokenizer case
@test str == rev_detokenizer(tokenized)                # multi-byte character de-tokenizer case


str = "Some of   100,000 households (usually, a minority) ate breakfast.  "

@test tokenized == String.(rev_tokenizer(str))        # multi-space condition
 

str = "The quick brown fox jumped over the lazy dog ⌣⌣"
tokenized = ["The", "quick", "brown", "fox", "jumped", "over", "the", "lazy", "dog", "⌣", "⇆⌣"]
@test tokenized == String.(rev_tokenizer(str))        # multi-byte character in input case
@test str == rev_detokenizer(tokenized)
