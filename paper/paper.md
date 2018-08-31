---
title: 'WordTokenizers.jl: basic tools for tokenizing natural language in Julia'
tags:
  - julialang
  - natural language processing (NLP)
  - tokenization
authors:
 - name: Lyndon White
   orcid: 0000-0003-1386-1646
   affiliation: 1

affiliations:
 - name: The University of Western Australia
   index: 1

date: 31 Aug 2018
bibliography: paper.bib
---

# Summary

WordTokenizers.jl is a tool help users of the Julia programming language ([@Julia]), work with natural language.
In natural language processing (NLP) tokenization refers to breaking a text up into parts -- the tokens.
Generally, tokenization refers to breaking a sentence up into words and other tokens such as punctuation.
Such _word tokenization_ also often includes some normalizing, such as correcting unusual spellings or removing all punctuations.
Complementary to word tokenization is _sentence segmentation_ (sometimes called _sentence tokenization_),
where a document is broken up into sentences, which can then be tokenized into words.
Tokenization and sentence segmentation are some of the most fundamental operations to be performed before applying most NLP or information retreval algorithms
WordTokenizers.jl exposes a number of tokenization and sentence segmentation functions to allow for this.

WordTokenizers.jl does not implement significant novel tokenizers or sentence segmenters.
Rather, it contains ports/implementations the well-established and commonly used algorithms.
At present, it contained rules-based methods primarily designed for English.
Several of the implementations are sourced from the Python NLTK project ([@NLTK1,@NLTK2]);
although these were in turn source from older pre-existing methods.
These include the very commonly used Penn Treebank Tokenizer ([@penntok]),
and the multilingual Tok-tok ([@toktok], [@toktokpub]).
Interesting, as an implementation detail, to implement many tokenizers,
it was found most convenient to first port them to sed,
and then use Julia's meta-programming capacity to generate Julia expressions from the sed code at compile time.

WordTokenizers.jl exposes a configurable default interface,
which allows the tokenizer and setence segmentors to be configured globally (where this is used).
This allowed for easy benchmarking and comparisons of different methods.
	

# References
