## Simple, general tokenizer, where the input has one sentence per line (thus only final period is tokenized)
## By Jon Dehdari, 2011-2016
## Changes this:  They thought, "Is 9.5 or 525,600 my favorite number?"  before seeing Dr. Bob's dog talk.
## To this:       They thought , " Is 9.5 or 525,600 my favorite number ? " before seeing Dr. Bob ' s dog talk .
# This is ported from https://github.com/jonsafari/tok-tok/blob/master/tok-tok.pl

s/ / /g					# replace no-break spaces with normal spaces
s/([،;؛¿!"\])}»›”؟¡%٪°±©®।॥…])/ $1 /g

## URL-unfriendly characters: [:/?#]
s!:(?!//)! : !g
s|\?(?!\S)| ? |g

# Line below is from `m{://} or m{\S+\.\S+/\S+} or s{/}{ / }g` # not exactly right: doesn't tokenize legit slash if on same line as URL
# s@(?<! (://)|(\S+\.\S+/\S+))/(?! (://)|(\S+\.\S+/\S+))@ / @g

s! /! / !g

s/& /&amp; /g		# replace problematic character with numeric character reference
s/\t/ &#9; /g		# replace problematic character with numeric character reference
s/\|/ &#124; /g		# replace problematic character with numeric character reference
s/(\p{Ps})/ $1 /g		# Open Punctionation
s/(\p{Pf})/ $1 /g		# Close_Punctuation
s/(,{2,})/ $1 /g		# fake German,Czech, etc.: „
s/(?<!,)([,،])(?![,\d])/ $1 /g	# don't tokenize 1,000,000
s/([({\[“‘„‚«‹「『])/ $1 /g	# misc. opening punctuation
s/(['’`])/ $1 /g		# just tokenize problematic hyphen/single quote, etc.
s/ ` ` / `` /g		# stupid quotes
s/ ' ' / '' /g		# stupid quotes
s/(\p{Sc})/ $1 /g	# Currency_Symbol
s/([–—])/ $1 /g		# en dash and em dash
s/(-{2,})/ $1 /g		# fake en-dash, etc.
s/(\.{2,})/ $1 /g	# treat multiple periods as a thing (eg. ellipsis)
s/(?<!\.)\.$/ ./g	# don't tokenize period unless it ends the line (and isn't preceded by another period)
s/(?<!\.)\.\s*(["'’»›”]) *$/ . $1/g	# don't tokenize period unless it's near the end of the line: eg. " ... stuff."
s/\s+$/\n/g			# rm trailing spaces
s/^\h+//g			# rm leading  spaces
s/ {2,}/ /g			# merge duplicate spaces
