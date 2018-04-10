using Base.Test
using WordTokenizers

@test penn_tokenize("hello there mate") == ["hello", "there", "mate"]
@test penn_tokenize("you shouldn't do that") == ["you", "should", "n't", "do", "that"]
@test penn_tokenize("Dr. Rob is here") == ["Dr.", "Rob", "is", "here"]
@test penn_tokenize("He (was) worried!") == ["He", "&", "was", "&", "worried", "&"]
