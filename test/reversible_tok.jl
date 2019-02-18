using Test
using WordTokenizers

@testset "default behaviour" begin
	str = "The quick brown fox jumped over the lazy dog"                
	tokenized = ["The", "quick", "brown", "fox", "jumped", "over", "the", "lazy", "dog"]

	@test tokenized == String.(rev_tokenizer(str))           
	@test str == rev_detokenizer(tokenized)              
end


@testset "multi-space" begin
    	str = "Some of   100,000 households (usually, a minority) ate breakfast.  "
    	tokenized = ["Some", "of", "100", "\ue302,\ue302", "000", "households", "(\ue302", "usually", "\ue302,", "a", "minority", "\ue302)", "ate", "breakfast", "\ue302."]

	@test tokenized == String.(rev_tokenizer(str))        
end


@testset "multi-byte character output" begin
	str = "Some of 100,000 households (usually, a minority) ate breakfast."
	tokenized = ["Some", "of", "100", "\ue302,\ue302", "000", "households", "(\ue302", "usually", "\ue302,", "a", "minority", "\ue302)", "ate", "breakfast", "\ue302."]

	@test tokenized == String.(rev_tokenizer(str))         
	@test str == rev_detokenizer(tokenized)                
end


@testset "multi-byte character input" begin
	str = "The quick brown fox jumped over the lazy dog ⌣⌣"
	tokenized = ["The", "quick", "brown", "fox", "jumped", "over", "the", "lazy", "dog", "⌣", "\ue302⌣"]

	@test tokenized == String.(rev_tokenizer(str))        
	@test str == rev_detokenizer(tokenized)
end
