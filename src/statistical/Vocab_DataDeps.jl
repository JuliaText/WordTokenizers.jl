abstract type ALBERT_V1 <: PretrainedTokenizer end
abstract type ALBERT_V2 <: PretrainedTokenizer end
abstract type GPT2 <: PretrainedTokenizer end

const vectors_albertversion1 = [
    ("albert_base_v1_30k-clean.vocab",
    "albert base version1 of size ~800kb download.",
    "1de4ad94a1b98f5f5f2c75af0f52bc85714d67b8578aa8f7650521bb123335c0",
    "https://raw.githubusercontent.com/tejasvaidhyadev/ALBERT.jl/master/src/Vocabs/albert_base_v1_30k-clean.vocab"),
    ("albert_large_v1_30k-clean.vocab",
    " albert large version1 of size ~800kb download.",
    "1de4ad94a1b98f5f5f2c75af0f52bc85714d67b8578aa8f7650521bb123335c0",
    "https://raw.githubusercontent.com/tejasvaidhyadev/ALBERT.jl/master/src/Vocabs/albert_large_v1_30k-clean.vocab"),
    ("albert_xlarge_v1_30k-clean.vocab",
    "albert xlarge version1 of size ~800kb download",
    "1de4ad94a1b98f5f5f2c75af0f52bc85714d67b8578aa8f7650521bb123335c0",
    "https://raw.githubusercontent.com/tejasvaidhyadev/ALBERT.jl/master/src/Vocabs/albert_xlarge_v1_30k-clean.vocab"),
    ("albert_xxlarge_v1_30k-clean.vocab",
    "albert xxlarge version1 of size ~800kb download",
    "1de4ad94a1b98f5f5f2c75af0f52bc85714d67b8578aa8f7650521bb123335c0",
    "https://raw.githubusercontent.com/tejasvaidhyadev/ALBERT.jl/master/src/Vocabs/albert_xxlarge_v1_30k-clean.vocab")
]


const vectors_albertversion2 = [
    ("albert_base_v2_30k-clean.vocab",
    "albert base version2 of size ~800kb download.",
    "1de4ad94a1b98f5f5f2c75af0f52bc85714d67b8578aa8f7650521bb123335c0",
    "https://raw.githubusercontent.com/tejasvaidhyadev/ALBERT.jl/master/src/Vocabs/albert_base_v2_30k-clean.vocab"),
    ("albert_large_v2_30k-clean.vocab",
    " albert large version2 of size ~800kb download.",
    "1de4ad94a1b98f5f5f2c75af0f52bc85714d67b8578aa8f7650521bb123335c0",
    "https://raw.githubusercontent.com/tejasvaidhyadev/ALBERT.jl/master/src/Vocabs/albert_large_v2_30k-clean.vocab"),
    ("albert_xlarge_v2_30k-clean.vocab",
    "albert xlarge version2 of size ~800kb download.",
    "1de4ad94a1b98f5f5f2c75af0f52bc85714d67b8578aa8f7650521bb123335c0",
    "https://raw.githubusercontent.com/tejasvaidhyadev/ALBERT.jl/master/src/Vocabs/albert_xlarge_v2_30k-clean.vocab"),
    ("albert_xxlarge_v2_30k-clean.vocab",
    "albert xxlarge version2 of size ~800kb download.",
    "1de4ad94a1b98f5f5f2c75af0f52bc85714d67b8578aa8f7650521bb123335c0",
    "https://raw.githubusercontent.com/tejasvaidhyadev/ALBERT.jl/master/src/Vocabs/albert_xxlarge_v2_30k-clean.vocab")
]

const vectors_gpt2 = ["encoder.json", "vocab.bpe"]

function init_vocab_datadeps()
    for (depname, description, sha, link) in vectors_albertversion1
        register(DataDep(depname,
            """
            sentencepiece albert vocabulary file by google research .
            Website: https://github.com/google-research/albert
            Author: Google Research
            Licence: Apache License 2.0
            $description
            """,
            link,
            sha
                ))
        append!(tokenizer_files(ALBERT_V1), ["$depname"])
    end

    for (depname, description, sha, link) in vectors_albertversion2
        register(DataDep(depname,
            """
            sentencepiece albert vocabulary file by google research .
            Website: https://github.com/google-research/albert
            Author: Google Research
            Licence: Apache License 2.0
            $description
            """,
            link,
            sha
                 ))
        append!(tokenizer_files(ALBERT_V2), ["$depname"])
    end

    register(DataDep("GPT2",
    """
    Pretrained gpt2 vocabulary and merges file by Open AI.
    Website: https://openai.com/blog/better-language-models/
    Author: Radford et al
    Licence: MIT
    All GPT2 Models are trained on same size vocabulary.
    """,
    ["https://openaipublic.blob.core.windows.net/gpt-2/models/117M/$(file)" for file in vectors_gpt2],
    "05805f21f823300551adf0646abe905eb036fb272f97c279f0d9c656c845ca46"))

    append!(tokenizer_files(GPT2), ["GPT2/$(file)" for file in vectors_gpt2])
end
