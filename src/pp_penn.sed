#!/bin/sed -f
# This is the penn.sed incorperating NTLK's modifications
# from https://github.com/oxinabox/nltk/blob/6d6b2794dfc660877996c6837a0dc5c5a7ef97ef/nltk/tokenize/treebank.py
# Basically it does not destroy punctuation


# Sed script to produce Penn Treebank tokenization on arbitrary raw text.
# Yeah, sure.

# expected input: raw text with ONE SENTENCE TOKEN PER LINE

# by Robert MacIntyre, University of Pennsylvania, late 1995.

# If this wasn't such a trivial program, I'd include all that stuff about
# no warrantee, free use, etc. from the GNU General Public License.  If you
# want to be picky, assume that all of its terms apply.  Okay?

# attempt to get correct directional quotes
# NLTK changes here
s=^"=``=g
s=(``)= \1=g
s=\([ ([{<]\)"=\1 `` =g
s=([ (\[{<])(\"|\'{2})=\1 `` =g
# close quotes handled at end

# NLTK punctuation settings
s=([:,])([^\d])= \1 \2=g
s=([:,])$= \1 =g
s=\.\.\.= ... =g
s=[;@#$%&]= \0 =g
s=([^\.])(\.)([\]\)}>"\']*)\s*$=\1 \2\3 =g
s=[?!]= \0 =g

s=([^'])' =\1 ' =g

# parentheses, brackets, etc.
# NLTK change is here, brackets are to be kept
s=[\]\[\(\)\{\}\<\>]= \0 =g


s=--= -- =g

# NOTE THAT SPLIT WORDS ARE NOT MARKED.  Obviously this isn't great, since
# you might someday want to know how the words originally fit together --
# but it's too late to make a better system now, given the millions of
# words we've already done "wrong".

# First off, add a space to the beginning and end of each line, to reduce
# necessary number of regexps.
s=$= =
s=^= =

#NLTK ending quotes
s="= '' =g
s=(\S)(\'\')=\1 \2 =g
s=([^' ])('[sS]|'[mM]|'[dD]|') =\1 \2 =g
s=([^' ])('ll|'LL|'re|'RE|'ve|'VE|n't|N'T) =\1 \2 =g


s= \([Cc]\)annot = \1an not =g
s= \([Dd]\)'ye = \1' ye =g
s= \([Gg]\)imme = \1im me =g
s= \([Gg]\)onna = \1on na =g
s= \([Gg]\)otta = \1ot ta =g
s= \([Ll]\)emme = \1em me =g
s= \([Mm]\)ore'n = \1ore 'n =g
s= '\([Tt]\)is = '\1 is =g
s= '\([Tt]\)was = '\1 was =g
s= \([Ww]\)anna = \1an na =g
# s= \([Ww]\)haddya = \1ha dd ya =g
# s= \([Ww]\)hatcha = \1ha t cha =g

# clean out extra spaces
s=  *= =g
s=^ *==g
