# Generate julialatex.el file
using LaTeX_Entities

open("julialatex.el", "w") do io
    for nam in LaTeX_Entities._tab.nam
        println(io, "(puthash \"", word, "\" \"", LaTeX_Entities.lookupname(nam), "\" julia-latexsubs)")
    end
end
