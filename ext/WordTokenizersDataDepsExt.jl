module WordTokenizersDataDepsExt

using DataDeps
using WordTokenizers: WordTokenizers, vectors_albertversion1, vectors_albertversion2

WordTokenizers.datadep_path(name::String) = @datadep_str name

function __init__()
    for (depname, description, sha, link) in [vectors_albertversion1; vectors_albertversion2]
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
    end
end

end # module
