# Generate completions.json
using LaTeX_Entities

open("completions.json", "w") do io
    println(io, "{")
    for nam in LaTeX_Entities._tab.nam
        println(io, "  \", word, ""\": \"", LaTeX_Entities.lookupname(nam), ""\",")
    end
    skip(io, -2)
    println(io)
    println(io, "}")
end
