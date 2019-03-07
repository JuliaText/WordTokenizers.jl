# Tok-Tok Tokenizer
# Replace non-breaking spaces with normal spaces.
const NON_BREAKING = ("\u00A0",) => " "

# Pad some funky punctuation.
const FUNKY_PUNCT_1 = string.(Tuple("،;؛¿!])}»›”؟¡%٪°±©®।॥…"))
# Pad more funky punctuation.
const FUNKY_PUNCT_2 = string.(Tuple("[“‘„‚«‹「『"))          
# Pad En dash and em dash
const EN_EM_DASHES = ("–—")

# Replace problematic character with numeric character reference.
const AMPERCENT = ("&",) => "&amp;"
const TAB = ("\t",) => "&#9;"
const PIPE = ("|",) => "&#124;"

# Just pad problematic (often neurotic) hyphen/single quote, etc.
const PROB_SINGLE_QUOTES = ("'", "’", "`")           
# Group ` ` stupid quotes ' ' into a single token.
const STUPID_QUOTES_1 = ("` `",) => "``"
const STUPID_QUOTES_2 = ("' '",) => "''"

# This is the \p{Open_Punctuation} from Perl's perluniprops
# see http://perldoc.perl.org/perluniprops.html          
const OPEN_PUNCT =(                 
        "\u0f3a", "\u0f3c", "\u169b", "\u201a", "\u201e", "\u2045", "\u207d", "\uff62",
        "\u208d", "\u2329", "\u2768", "\u276a", "\u276c", "\u276e", "\u2770", "\u2772",
        "\u2774", "\u27c5", "\u27e6", "\u27e8", "\u27ea", "\u27ec", "\u27ee", "\u2983",
        "\u2985", "\u2987", "\u2989", "\u298b", "\u298d", "\u298f", "\u2991", "\u2993",
        "\u2995", "\u2997", "\u29d8", "\u29da", "\u29fc", "\u2e22", "\u2e24", "\u2e26",
        "\u2e28", "\u3008", "\u300a", "\u300c", "\u300e", "\u3010", "\u3014", "\u3016",
        "\u3018", "\u301a", "\u301d", "\ufd3e", "\ufe17", "\ufe35", "\ufe37", "\ufe39",
        "\ufe3b", "\ufe3d", "\ufe3f", "\ufe41", "\ufe43", "\ufe47", "\ufe59", "\ufe5b",
        "\ufe5d", "\uff08", "\uff3b", "\uff5b", "\uff5f")
    
# This is the \p{Close_Punctuation} from Perl's perluniprops            
const CLOSE_PUNCT =(
        "\u0f3b", "\u0f3d", "\u169c", "\u2046", "\u207e", "\u208e", "\u232a", "\uff63",
        "\u2769", "\u276b", "\u276d", "\u276f", "\u2771", "\u2773", "\u2775", "\u27c6",
        "\u27e7", "\u27e9", "\u27eb", "\u27ed", "\u27ef", "\u2984", "\u2986", "\u2988",
        "\u298a", "\u298c", "\u298e", "\u2990", "\u2992", "\u2994", "\u2996", "\u2998",
        "\u29d9", "\u29db", "\u29fd", "\u2e23", "\u2e25", "\u2e27", "\u2e29", "\u3009",
        "\u300b", "\u300d", "\u300f", "\u3011", "\u3015", "\u3017", "\u3019", "\u301b",
        "\u301e", "\u301f", "\ufd3f", "\ufe18", "\ufe36", "\ufe38", "\ufe3a", "\ufe3c",
        "\ufe3e", "\ufe40", "\ufe42", "\ufe44", "\ufe48", "\ufe5a", "\ufe5c", "\ufe5e",
        "\uff09", "\uff3d", "\uff5d", "\uff60")
    
# This is the \p{Close_Punctuation} from Perl's perluniprops             
const CURRENCY_SYM = (
        "\u00a2", "\u00a3", "\u00a4", "\u00a5", "\u058f", "\u060b", "\u09f2", "\u09f3", 
        "\u0af1", "\u0bf9", "\u0e3f", "\u17db", "\u20a0", "\u20a1", "\u20a2", "\u20a3",
        "\u20a4", "\u20a5", "\u20a6", "\u20a7", "\u20a8", "\u20a9", "\u20aa", "\u20ab",
        "\u20ac", "\u20ad", "\u20ae", "\u20af", "\u20b0", "\u20b1", "\u20b2", "\u20b3",
        "\u20b4", "\u20b5", "\u20b6", "\u20b7", "\u20b8", "\u20b9", "\u20ba", "\ua838",
        "\ufdfc", "\ufe69", "\uff04", "\uffe0", "\uffe1", "\uffe5", "\uffe6", "\u09fb",)

# Left/Right strip, i.e. remove heading/trailing spaces.
const LSTRIP = (" ",) => ""           
const RSTRIP = ("\r", "\n", "\t", "\f", "\v",) => "\n"  
# Merge multiple spaces.
const ONE_SPACE = ("  ",) => " "

rules_atoms = [
        CURRENCY_SYM,
        FUNKY_PUNCT_1,
        FUNKY_PUNCT_2,
        EN_EM_DASHES,
        PROB_SINGLE_QUOTES,
        OPEN_PUNCT,
        CLOSE_PUNCT    
    ]
rules_atoms = Tuple(Iterators.flatten(rules_atoms))

rules_replaces = [
        NON_BREAKING,
        AMPERCENT,
        TAB,
        PIPE,
        STUPID_QUOTES_1,
        STUPID_QUOTES_2,
        ONE_SPACE
    ]
rules_replaces = vcat(rules_replaces...)

rules_splitting = vcat(LSTRIP, RSTRIP)

function toktok_tokenize(instring::AbstractString)
    ts = TokenBuffer(instring)
    isempty(ts.input) && return ts.tokens
 
    flag = handle_final_periods(ts)
    
    while !isdone(ts) && ts.idx <= flag
        url_handler1(ts) ||   # these url handlers have priority over others
        url_handler2(ts) ||
        url_handler3(ts) || 
        url_handler4(ts) ||
        atoms(ts, rules_atoms) ||
        replaces(ts, rules_replaces) || 
        replaces(ts, rules_splitting, boundary = true) ||
        repeated_character_seq(ts, ",", 2) || 
        repeated_character_seq(ts, "-", 2) || 
        repeated_character_seq(ts, ".", 2) ||
        number(ts) ||
        spaces(ts) || 
        character(ts)
    end
    flush!(ts)
    return ts.tokens
end

"""
    handle_final_periods(::TokenBuffer)
Handles the following rules using TokenBuffer API:  
FINAL_PERIOD_1
FINAL_PERIOD_2
"""
function handle_final_periods(ts::TokenBuffer)
    flag = length(ts.input)
    # handles FINAL_PERIOD_1 = r"(?<!\.)\.$"
    if length(ts.input) >= 2 && ts.input[end] == "." && ts.input[end-1] != "."
        flush!(ts, ".")
        flag -= 1
    end

    # handles FINAL_PERIOD_2 = r"(?<!\.)\.\s*(["'’»›”]) *$"
    if ts.input[end] in string.(Tuple("“”‘’›"))
        i = flag - 1
        while ts.input[i] in RSTRIP[1]
            i -= 1
        end
        if ts.input[i] == "."
            flag = i - 1
            flush!(ts, ts.input[i:end])
        end
    end
    return flag
end

"""
    url_handler1(::TokenBuffer)
Handles this rule from python using TokenBuffer API:  
URL_FOE_1 = re.compile(r':(?!//)'), r' : '  
"""
function url_handler1(ts::TokenBuffer)
    str = ":"
    pattern = "//"
    if ts.idx + length(pattern) <= length(ts.input) && ts.input[ts.idx] == str && 
       ts.input[ts.idx + 1: ts.idx + length(pattern)] != pattern
        flush!(ts, str)
        return true
    elseif ts.idx + length(pattern) <= length(ts.input) && ts.input[ts.idx] == str
        for i in 1: length(pattern) + 1
            push!(ts.buffer, ts.input[ts.idx])
            ts.idx += 1
        end
        return true
    end
    return false
end

"""
    url_handler2(::TokenBuffer)
Handles this rule from python using TokenBuffer API:  
URL_FOE_2 = re.compile(r'\\?(?!\\S)'), r' ? '  
"""
function url_handler2(ts::TokenBuffer)
    str = "?"
    if ts.idx + 1 <= length(ts.input) && ts.input[ts.idx] == str && isspace(ts.input[ts.idx + 1])
        flush!(ts, str)
        return true
    elseif ts.idx + 1 <= length(ts.input) && ts.input[ts.idx] == str
        for i in 1: 2
            push!(ts.buffer, ts.input[ts.idx])
            ts.idx += 1
        end
        return true
    end
    return false
end

"""
    url_handler3(::TokenBuffer)
Handles this rule from python using TokenBuffer API:  
URL_FOE_3 = re.compile(r'(://)[\\S+\\.\\S+/\\S+][/]'), ' / '
"""
function url_handler3(ts::TokenBuffer)
    str = "://"
    pattern = [":", "/", "."]
    if lookahead(ts, str) && ts.idx + 4 <= length(ts.input)
        if (ts.input[ts.idx + length(str)] in pattern || isspace(ts.input[ts.idx + length(str)])) && 
            ts.input[ts.idx + length(str) + 1] == "/"
            flush!(ts, "/")
            ts.idx += 4
            return true
        else
            for i in 1: 5
                push!(ts.buffer, ts.input[ts.idx])
                ts.idx += 1
            end
            return true
        end
    end
    return false
end

"""
    url_handler4(::TokenBuffer)
Handles this rule from python using TokenBuffer API:  
URL_FOE_4 = re.compile(r' /'), r' / '
"""
function url_handler4(ts::TokenBuffer)
    if lookahead(ts, " /")
        flush!(ts, "/")
        ts.idx += 1
        return true
    elseif lookahead(ts, "/")
        push!(ts.buffer, '/')
        ts.idx += 1
    end
    return false
end


"""
    repeated_character_seq(::TokenBuffer, char, min_repeats=2)
Matches sequences of characters that are repreated at least `min_repeats` times.
Flushes them.
"""
function repeated_character_seq(ts, char, min_repeats=2)
  i = ts.idx
  while i <= length(ts.input) && (ts[i]==char)
    i += 1
  end
  seq_end_ind = i - 1  # remove last failing step

  seq_end_ind - ts.idx < min_repeats && return false  # not enough repeats.
  flush!(ts, String(ts[ts.idx : seq_end_ind]))
  ts.idx = seq_end_ind + 1 
  return true
end
