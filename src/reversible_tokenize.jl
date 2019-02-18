# A simple reversible tokenizer
"""
A simple reversible tokenizer

```
tokenized = rev_tokenizer(instring)
de_tokenized = rev_detokenizer(token)
```

The rev_tokenize tokenizer splits into token based on space, punctuations and special symbols and in 
addition it leaves some merge-symbols (`'\ue302'`) for the tokens to be re-arranged when needed 
using the rev_detokenize.
It uses a character based approach for splitting and re-merging.

Parameters:

- instring: Input string to be tokenized 
- token: Collection to tokens i.e String Array

"""
const MERGESYMBOL = '\ue302'

function is_weird(c::AbstractChar)
    return !(isletter(c) || isnumeric(c) || isspace(c))
end

function nth_ind(instring, startind, n)
    
    if n == 0 
        return thisind(instring, startind)
        
    elseif n < 0
        return prevind(instring, nth_ind(instring, startind , n+1))
        
    else
        return nextind(instring, nth_ind(instring, startind, n-1))
    end
end


function rev_tokenizer(instring::AbstractString)
    ans = IOBuffer()
    for ind in eachindex(instring)
        c   = instring[thisind(instring, ind)]
        c_p = thisind(instring, ind) > 1 ? instring[prevind(instring, ind)] : c
        c_n = thisind(instring, ind) < thisind(instring, lastindex(instring)) ? instring[nextind(instring, ind)] : c
        
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


function rev_detokenizer(instring::Array{String})
    ind = 1
    ans = IOBuffer()
    instring = join(instring, " ")
    last_index = thisind(instring, lastindex(instring))
    while  thisind(instring, ind) <= last_index
        current_ind = thisind(instring, ind)
        c    = instring[thisind(instring, ind)]
        c_p  = current_ind > 1 ? instring[prevind(instring, ind)] : c
        c_n  = current_ind < last_index ? instring[nextind(instring, ind)] : c
        c_pp = current_ind > nextind(instring, 1) ? instring[nth_ind(instring, ind, -2)] : c
        c_nn = current_ind < prevind(instring, last_index) ? instring[nth_ind(instring, ind, 2)] : c
        
        if c * c_n == ' ' * MERGESYMBOL && is_weird(c_nn)
            ind = nth_ind(instring, ind, 2)
        elseif is_weird(c) && c_n * c_nn == MERGESYMBOL * ' '
            write(ans, c)
            ind = nth_ind(instring, ind, 3)
        else
            write(ans, c)
            ind = nextind(instring, ind)
        end
    end
    return String(take!(ans))
end
