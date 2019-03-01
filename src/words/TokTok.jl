# Tok-Tok Tokenizer
# Replace non-breaking spaces with normal spaces.

const NON_BREAKING = ["\u00A0"], " "

# Pad some funky punctuation.
const FUNKY_PUNCT_1 = String.(split("،;؛¿!])}»›”؟¡%٪°±©®।॥…", ""))
# Pad more funky punctuation.
const FUNKY_PUNCT_2 = String.(split("[“‘„‚«‹「『", ""))          
# Pad En dash and em dash
const EN_EM_DASHES = ["–—"]

# Replace problematic character with numeric character reference.
const AMPERCENT = ["&"], "&amp;"
const TAB = ["\t"], "&#9;"
const PIPE = ["|"], "&#124;"

# Just pad problematic (often neurotic) hyphen/single quote, etc.
const PROB_SINGLE_QUOTES = ["'", "’", "`"]           
# Group ` ` stupid quotes ' ' into a single token.
const STUPID_QUOTES_1 = ["` `"], "``"
const STUPID_QUOTES_2 = ["' '"], "''"

# This is the \p{Open_Punctuation} from Perl's perluniprops
# see http://perldoc.perl.org/perluniprops.html          
const OPEN_PUNCT =[                 
        "\u0f3a", "\u0f3c", "\u169b", "\u201a", "\u201e", "\u2045", "\u207d", "\uff62",
        "\u208d", "\u2329", "\u2768", "\u276a", "\u276c", "\u276e", "\u2770", "\u2772",
        "\u2774", "\u27c5", "\u27e6", "\u27e8", "\u27ea", "\u27ec", "\u27ee", "\u2983",
        "\u2985", "\u2987", "\u2989", "\u298b", "\u298d", "\u298f", "\u2991", "\u2993",
        "\u2995", "\u2997", "\u29d8", "\u29da", "\u29fc", "\u2e22", "\u2e24", "\u2e26",
        "\u2e28", "\u3008", "\u300a", "\u300c", "\u300e", "\u3010", "\u3014", "\u3016",
        "\u3018", "\u301a", "\u301d", "\ufd3e", "\ufe17", "\ufe35", "\ufe37", "\ufe39",
        "\ufe3b", "\ufe3d", "\ufe3f", "\ufe41", "\ufe43", "\ufe47", "\ufe59", "\ufe5b",
        "\ufe5d", "\uff08", "\uff3b", "\uff5b", "\uff5f"]
    
# This is the \p{Close_Punctuation} from Perl's perluniprops            
const CLOSE_PUNCT =[
        "\u0f3b", "\u0f3d", "\u169c", "\u2046", "\u207e", "\u208e", "\u232a", "\uff63",
        "\u2769", "\u276b", "\u276d", "\u276f", "\u2771", "\u2773", "\u2775", "\u27c6",
        "\u27e7", "\u27e9", "\u27eb", "\u27ed", "\u27ef", "\u2984", "\u2986", "\u2988",
        "\u298a", "\u298c", "\u298e", "\u2990", "\u2992", "\u2994", "\u2996", "\u2998",
        "\u29d9", "\u29db", "\u29fd", "\u2e23", "\u2e25", "\u2e27", "\u2e29", "\u3009",
        "\u300b", "\u300d", "\u300f", "\u3011", "\u3015", "\u3017", "\u3019", "\u301b",
        "\u301e", "\u301f", "\ufd3f", "\ufe18", "\ufe36", "\ufe38", "\ufe3a", "\ufe3c",
        "\ufe3e", "\ufe40", "\ufe42", "\ufe44", "\ufe48", "\ufe5a", "\ufe5c", "\ufe5e",
        "\uff09", "\uff3d", "\uff5d", "\uff60"]
    
# This is the \p{Close_Punctuation} from Perl's perluniprops             
const CURRENCY_SYM = [
        "\xa2", "\xa3", "\xa4", "\xa5", "\u058f", "\u060b", "\u09f2", "\u09f3", "\u09fb",
        "\u0af1", "\u0bf9", "\u0e3f", "\u17db", "\u20a0", "\u20a1", "\u20a2", "\u20a3",
        "\u20a4", "\u20a5", "\u20a6", "\u20a7", "\u20a8", "\u20a9", "\u20aa", "\u20ab",
        "\u20ac", "\u20ad", "\u20ae", "\u20af", "\u20b0", "\u20b1", "\u20b2", "\u20b3",
        "\u20b4", "\u20b5", "\u20b6", "\u20b7", "\u20b8", "\u20b9", "\u20ba", "\ua838",
        "\ufdfc", "\ufe69", "\uff04", "\uffe0", "\uffe1", "\uffe5", "\uffe6"]

# Use for tokenizing URL-unfriendly characters: [:/?#]
const URL_FOE_3 = [":", "/", "+", ".", "\r", "\n", "\t", "\f", "\v"], "/"
const URL_FOE_4 = [" /"], "/"

# Left/Right strip, i.e. remove heading/trailing spaces.
const LSTRIP = [" "], ""           
const RSTRIP = ["\r", "\n", "\t", "\f", "\v"], "\n"  
# Merge multiple spaces.
const ONE_SPACE = ["  "], " "


const rules_atoms = [
        FUNKY_PUNCT_1,
        FUNKY_PUNCT_2,
        EN_EM_DASHES,
        PROB_SINGLE_QUOTES,
        OPEN_PUNCT,
        CLOSE_PUNCT,
        CURRENCY_SYM
    ]

const rules_replaces = [
	NON_BREAKING,
        AMPERCENT,
        TAB,
        PIPE,
        STUPID_QUOTES_1,
        STUPID_QUOTES_2,
        URL_FOE_3,
        URL_FOE_4,
        ONE_SPACE
    ]

function toktok_tokenize(instring::AbstractString)
    ts = TokenBuffer(instring)
    isempty(input) && return ts.tokens
 
    flag = length(ts.input)
    # handles FINAL_PERIOD_1 = r"(?<!\.)\.$"
    if ts.input[end-1 : end] != ".."
        flush!(ts, ".")
        flag -= 1
    end

    # handles FINAL_PERIOD_2 = r"(?<!\.)\.\s*(["'’»›”]) *$"
    if ts.input[end] in String.split("“”‘’›")
        i = flag - 1
        while ts.input[i] in RSTRIP[1]
            i -= 1
        end
        if ts.input[i] == "."
            flag = i - 1
            flush!(ts, ts.input[i:end])
        end
    end
 
    while !isdone(ts) && ts.idx <= flag
       atoms(ts, vcat(rules_atoms...)) || replaces(ts, vcat(rules_replaces...)) || replaces(ts, vcat(LSTRIP, RSTRIP), boundary = true)
       url_handler(ts, ":", "//") || url_handler(ts, "?", RSTRIP[1]) 
       repeated_character_seq(ts, ",", 2) || repeated_character_seq(ts, "-", 2) || repeated_character_seq(ts, ".", 2) 
       number(ts) || character(ts)
    end
    return ts.tokens
end


"""
    ulr_handler(::TokenBuffer, string, pattern)
This handles type of regex where a string is to be matched and it must not be 
proceeded by some specific pattern.
Flushes them. 
Eg. URL_FOE_1 = r":(?!//)"
    URL_FOE_2 = r"\\?(?!\\S)"
"""
function url_handler(ts::TokenBuffer, str, pattern::String)
    if lookahead(ts, str)
        for i in 1: length(pattern)
            ts.input[ts.idx + length(str) -1 + i] != pattern[i] || return false
        end
        flush!(ts, str)
        return true
    end
    return false
end

function url_handler(ts::TokenBuffer, str, patterns::Array{String})
    if lookahead(ts, str)
        for pattern in patterns
            for i in 1: length(pattern)
                ts.input[ts.idx + length(str) -1 + i] != pattern[i] || return false
            end
            flush!(ts, str)
            return true
        end
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

  seq_end_ind - ts.ind < min_repeats && return false  # not enough repeats.
  flush!(ts, String(ts[ts.idx : seq_end_ind]))
  ts.idx = seq_end_ind + 1 
  return true
end
