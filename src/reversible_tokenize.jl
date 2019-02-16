# A simple reversible tokenizer
"""
A simple reversible tokenizer

```
tokenized = rev_tokenizer(instring)
de_tokenized = rev_detokenizer(token)
```

The rev_tokenize tokenizer splits into token based on space and punctuations and in 
addition it leaves some MERGESYMBOLS for the tokens to be re-arranged when needed 
using the rev_detokenize.
It uses a character based approach for splitting and re-merging.

Parameters:

- instring		= Input string to be tokenized 
- token			= Collection to tokens i.e String Array

"""
MERGESYMBOL = '⇆'

function is_weird(c::AbstractChar)
    return !(isletter(c) || isnumeric(c) || isspace(c))
end


function rev_tokenizer(instring::AbstractString)
    ans = IOBuffer()
    for ind in eachindex(instring)
        c = instring[ind]
        c_p = ind > 1 ? instring[ind-1] : c
        c_n = ind < length(instring) ? instring[ind+1] : c
        
        if !is_weird(c)
            write(ans, c)
        else
            if !isspace(c_p)
                write(ans, " ", MERGESYMBOL)
            end
            write(ans, c)
            if !isspace(c_n) && !is_weird(c_n)
                write(ans, MERGESYMBOL, " ")
            end
        end
       
    end
    return split(String(take!(ans)))
end


function rev_detokenizer(instring)
    ind = 1
    ans = IOBuffer()
    instring = join(instring, " ")
    last_index = thisind(instring, lastindex(instring))
    while  thisind(instring, ind) <= last_index
        c    = instring[thisind(instring, ind)]
        c_p  = thisind(instring, ind) > 1 ? instring[prevind(instring, ind)] : c
        c_n  = thisind(instring, ind) < last_index ? instring[nextind(instring, ind)] : c
        c_pp = thisind(instring, ind) > nextind(instring, 1) ? instring[prevind(instring, prevind(instring, ind))] : c
        c_nn = thisind(instring, ind) < prevind(instring, last_index) ? instring[nextind(instring, nextind(instring, ind))] : c
        
        if c * c_n == ' ' * MERGESYMBOL && is_weird(c_nn)
            ind = nextind(instring, nextind(instring, ind))
        elseif is_weird(c) && c_n * c_nn == MERGESYMBOL * ' '
            write(ans, c)
            ind = nextind(instring, nextind(instring, nextind(instring, ind)))
        else
            write(ans, c)
            ind = nextind(instring, ind)
        end
    end
    return String(take!(ans))
end
