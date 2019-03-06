using Test
using WordTokenizers

@testset "default behaviour" begin
	str = "Is 9.5 or 525,600 my favorite number?"                
	tokenized = ["Is", "9.5", "or", "525,600", "my", "favorite", "number", "?"]

	@test tokenized == toktok_tokenize(str)           
	
	str = "This \xa1124, is a sentence with weird \u00a2symbols \u2026 appearing everywhere \xbf"
	tokenized = ["This", "\xa1", "124", ",", "is", "a", "sentence", "with", "weird", "\u00a2", "symbols", 
                      "\u2026", "appearing", "everywhere", "\xbf"]
	@test tokenized == toktok_tokenize(str)	            
end

