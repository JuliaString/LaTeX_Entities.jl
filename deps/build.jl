# License is MIT: http://julialang.org/license
# Portions of this are based on code from julia/base/latex_symbols.jl
#
# Mapping from LaTeX math symbol to the corresponding Unicode codepoint.
# This is used for tab substitution in the REPL.

println("Running LaTeX build in ", pwd())

using LightXML
using StrTables
include("../src/latex_table.jl")

#const dpath = "http://www.w3.org/Math/characters/"
const dpath = "http://www.w3.org/2003/entities/2007xml/"
const fname = "unicode.xml"
#const lpath = "http://mirror.math.ku.edu/tex-archive/macros/latex/contrib/unicode-math/"
#const lpath = "http://mirror.unl.edu/ctan/macros/latex/contrib/unicode-math/"
const lpath = "https://raw.githubusercontent.com/wspr/unicode-math/master/"
const lname = "unicode-math-table.tex"

# Get manual additions to the tables
include("../src/manual_latex.jl")

const datapath = joinpath(Pkg.dir(), "LaTeX_Entities", "data")

const empty_str = ""
const element_types = ("mathlatex", "AMS", "IEEE", "latex")

function get_math_symbols(dpath, fname)
    lname = joinpath(datapath, fname)
    println("Save to: ", lname)
    if isfile(fname)
        vers = (now(), lname)
    else
        vers = (now(), string(dpath, fname))
        download(vers[2], lname)
    end
    xdoc = parse_file(lname)

    latex_sym  = [Pair{String, String}[] for i = 1:length(element_types)]

    info = Tuple{Int, Int, String, String, String}[]
    count = 0
    # Handle differences in versions of unicode.xml document
    rt = root(xdoc)
    top = find_element(rt, "charlist")
    top == nothing || (rt = top)
    for c in child_nodes(rt)
        if name(c) == "character" && is_elementnode(c)
            ce = XMLElement(c)
            for (ind, el) in enumerate(element_types)
                latex = find_element(ce, el)
                if latex == nothing
                    # println("##\t", attribute(ce, "id"), "\t", ce)
                    continue
                end
                L = strip(content(latex))
                id = attribute(ce, "id")
                U = string(map(s -> Char(parse(Int, s, 16)), split(id[2:end], "-"))...)
                mtch = ismatch(r"^\\[A-Za-z][A-Za-z0-9]*(\{[A-Za-z0-9]\})?$", L)
                println("#", count += 1, "\t", mtch%Int, " id: ", id, "\tU: ", U, "\t", L)
                if mtch
                    L = L[2:end] # remove initial \
                    if length(U) == 1 && isascii(U[1])
                        # Don't store LaTeX names for ASCII characters
                        typ = 0
                    else
                        typ = 1
                        push!(latex_sym[ind], L => U)
                    end
                    push!(info, (ind, typ, L, U, empty_str))
                end
            end
        end
    end
    latex_sym, vers, info
end

function add_math_symbols(dpath, fname)
    lname = joinpath(datapath, fname)
    println("Save to: ", lname)
    if isfile(fname)
        vers = (now(), lname)
    else
        vers = (now(), string(dpath, fname))
        download(vers[2], lname)
    end
    latex_sym = Pair{String, String}[]
    info = Tuple{Int, Int, String, String, String}[]
    open(lname) do f
        for L in eachline(f)
            x = map(s -> rstrip(s, [' ','\t','\n']),
                    split(replace(L, r"[{}\"]+", "\t"), "\t"))
            ch = Char(parse(Int, x[2], 16))
            nam = x[3][2:end]
            startswith(nam, "math") && (nam = nam[5:end])
            if isascii(ch)
                typ = 0 # ASCII
            elseif Base.is_id_char(ch)
                typ = 1 # identifier
            elseif Base.isoperator(Symbol(ch))
                typ = 2 # operator
            else
                typ = 3
            end
            typ != 0 && push!(latex_sym, nam => string(ch))
            push!(info, (2, typ, nam, string(ch), x[5]))
        end
    end
    latex_sym, vers, info
end

function sortsplit!{T}(index::Vector{UInt16}, vec::Vector{Tuple{T, UInt16}}, base)
    sort!(vec)
    len = length(vec)
    valvec = Vector{T}(len)
    indvec = Vector{UInt16}(len)
    for (i, val) in enumerate(vec)
        valvec[i], ind = val
        indvec[i] = ind
        index[ind] = UInt16(base + i)
    end
    base += len
    valvec, indvec, base
end

function make_tables()
    sym1, ver1, inf1 = get_math_symbols(dpath, fname)
    sym2, ver2, inf2 = add_math_symbols(lpath, lname)

    latex_sym = [manual_latex, sym2, sym1...]
    et = ("manual", "tex", element_types...)

    latex_set = Dict{String,String}()

    # Select the first name found, ignore duplicates
    symnam = String[]
    symval = String[]
    for (ind, sym_set) in enumerate(latex_sym)
        countdup = 0
        countdiff = 0
        for (nam, val) in sym_set
            old = get(latex_set, nam, "")
            if old == ""
                push!(latex_set, nam => val)
                push!(symnam, nam)
                push!(symval, val)
            elseif val != old
                countdiff += 1
            else
                countdup += 1
            end
        end
        println(countdup, " duplicates, ", countdiff, " overwritten out of ", length(sym_set),
                " found in ", et[ind])
    end
    println(length(symval), " distinct entities found")
    
    # We want to build a table of all the names, sort them, then create a StrTable out of them
    srtnam = sortperm(symnam)
    srtval = symval[srtnam] # Values, sorted the same as srtnam

    # BMP characters
    l16 = Vector{Tuple{UInt16, UInt16}}()
    # non-BMP characters (in range 0x10000 - 0x1ffff)
    l32 = Vector{Tuple{UInt16, UInt16}}()
    # two characters packed into UInt32, first character in high 16-bits
    l2c = Vector{Tuple{UInt32, UInt16}}()

    for i in eachindex(srtnam)
        chrs = convert(Vector{Char}, srtval[i])
        length(chrs) > 2 && error("Too long sequence of characters $chrs")
        if length(chrs) == 2
            (chrs[1] > '\uffff' || chrs[2] > '\uffff') &&
                error("Character $(chrs[1]) or $(chrs[2]) > 0xffff")
            push!(l2c, (chrs[1]%UInt32<<16 | chrs[2]%UInt32, i))
        elseif chrs[1] > '\U1ffff'
            error("Character $(chrs[1]) too large: $(UInt32(chrs[1]))")
        elseif chrs[1] > '\uffff'
            push!(l32, ((chrs[1]-0x10000)%UInt32, i))
        else
            push!(l16, (chrs[1]%UInt16, i))
        end
    end

    # We now have 3 vectors, for single BMP characters, for non-BMP characters, and for 2 BMP chars
    # each has the value and a index into the name table
    # We need to create a vector the same size as the name table, that gives the index
    # of into one of the three tables, in order to go from names to 1 or 2 output characters
    # We also need, for each of the 3 tables, a sorted vector that goes from the indices
    # in each table to the index into the name table (so that we can find multiple names for
    # each character)

    indvec = Vector{UInt16}(length(srtnam))
    vec16, ind16, base32 = sortsplit!(indvec, l16, 0)
    vec32, ind32, base2c = sortsplit!(indvec, l32, base32)
    vec2c, ind2c, basefn = sortsplit!(indvec, l2c, base2c)

    (VER,  base32%UInt32, base2c%UInt32,
     StrTable(symnam[srtnam]), indvec,
     vec16, ind16, vec32, ind32, vec2c, ind2c),
    (ver1, ver2), (inf1, inf2)
end

println("Creating tables")
tup, ver, inf = make_tables()
savfile = joinpath(datapath, "latex.dat")
println("Saving tables to ", savfile)
StrTables.save(savfile, tup)
println("Done")
