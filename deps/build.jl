# License is MIT: https://github.com/JuliaString/LaTeX_Entities/LICENSE.md
#
# Portions of this are based on code from julia/base/latex_symbols.jl
#
# Mapping from LaTeX math symbol to the corresponding Unicode codepoint.
# This is used for tab substitution in the REPL.

println("Running LaTeX build in ", pwd())

using LightXML
using StrTables

VER = UInt32(1)

#const dpath = "http://www.w3.org/Math/characters/"
const dpath = "http://www.w3.org/2003/entities/2007xml/"
const fname = "unicode.xml"
#const lpath = "http://mirror.math.ku.edu/tex-archive/macros/latex/contrib/unicode-math/"
const lpath = "https://raw.githubusercontent.com/wspr/unicode-math/master/"
const lname = "unicode-math-table.tex"

const disp = [false]

# Get manual additions to the tables
include("../src/manual_latex.jl")

const datapath = joinpath(pkg_dir("LaTeX_Entities"), "data")

const empty_str = ""
const element_types = ("mathlatex", "AMS", "IEEE", "latex")

function get_math_symbols(dpath, fname)
    lname = joinpath(datapath, fname)
    if isfile(fname)
        println("Loaded: ", lname)
        vers = lname
    else
        vers = string(dpath, fname)
        download(vers, lname)
        println("Saved to: ", lname)
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
                    disp[] && println("##\t", attribute(ce, "id"), "\t", ce)
                    continue
                end
                L = strip(content(latex))
                id = attribute(ce, "id")
                U = string(map(s -> Char(parse_hex(UInt32, s)), split(id[2:end], "-"))...)
                mtch = _contains(L, r"^\\[A-Za-z][A-Za-z0-9]*(\{[A-Za-z0-9]\})?$")
                disp[] &&
                    println("#", count += 1, "\t", mtch%Int, " id: ", id, "\tU: ", U, "\t", L)
                if mtch
                    L = L[2:end] # remove initial \
                    if length(U) == 1 && isascii(U[1])
                        # Don't store LaTeX names for ASCII characters
                        typ = 0
                    else
                        typ = 1
                        push!(latex_sym[ind], String(L) => U)
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
    if isfile(fname)
        println("Loaded: ", lname)
        vers = lname
    else
        vers = string(dpath, fname)
        download(vers, lname)
        println("Saved to: ", lname)
    end
    latex_sym = Pair{String, String}[]
    info = Tuple{Int, Int, String, String, String}[]
    open(lname) do f
        for L in eachline(f)
            (isempty(L) || L[1] == '%') && continue
            x = map(s -> rstrip(s, [' ','\t','\n']),
                    split(_replace(L, r"[{}\"]+" => "\t"), "\t"))
            ch = Char(parse_hex(UInt32, x[2]))
            nam = String(x[3][2:end])
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

#=
 standard | v7.0  | proposed | type
----------|-------|----------|------
mscr	  | scr	  | sc       | script
msans	  | sans  | ss       | sans-serif
Bbb       | bb	  | ds       | blackboard / doublestruck
mfrak     | frak  | fr       | fraktur
mtt	  | tt	  | tt       | mono
mit	  | it	  | it       | italic
mitsans   | isans | is       | italic sans-serif
mitBbb    | bbi	  | id       | italic blackboard / doublestruct
mbf	  | bf	  | bd       | bold
mbfscr	  | bscr  | bc       | bold script
mbfsans   | bsans | bs       | bold sans-serif
mbffrak   | bfrak | bf       | bold fraktur
mbfit	  | bi	  | bi       | bold italic
mbfitsans | bisans| bis      | bold italic sans-serif
                  | gr       | greek
it<greek>         | ig       | italic greek
bf<greek>         | bg       | bold greek
bi<greek>	  | big      | bold italic greek
bsans<greek>	  | bsg      | bold sans-serif greek
bisans<greek>     | bisg     | bold italic sans-serif greek
                  | gv       | greek variant
mitvar<greek>     | iv       | italic greek variant
mbfvar<greek>     | bv       | bold greek variant
mbfitvar<greek>	  | biv      | bold italic greek variant
mbfsansvar<greek> | bsv      | bold sans-serif greek variant
mbfitsansvar<greek> | bisv   | bold italic sans-serif greek variant

i -> imath                     ı
=#
function add_name(dic::Dict, val, nam)
    println("\e[s$val\e[u\e[4C$nam")
    if haskey(dic, val)
        push!(dic[val], nam)
    else
        dic[val] = Set((nam,))
    end
end

function replace_suffix(dic, val, nam, off, pref, list)
    for (suf, rep) in list
        nam[off:end] == suf && (add_name(dic, val, pref * suf) ; return true)
    end
    false
end

replace_all(dic, val, nam, off, grpref, gvpref, digpref) =
    replace_suffix(dic, val, nam, off, grpref, greek_letters) ||
    replace_suffix(dic, val, nam, off, gvpref, var_greek) ||
    replace_suffix(dic, val, nam, off, digpref, digits)

function shorten_names(names::Dict)
    valtonam = Dict{String,Set{String}}()
    for (nam, val) in names
        for (oldnam, newnam) in replace_name
            nam == oldnam && (nam = newnam; break)
        end
        # Special handling of "up"/"mup" prefixes
        if startswith("up", nam)
            # Add it later when processing "mup" prefix if they have the same value
            get(names, "m" * nam, "") == val && continue
        elseif startswith("mup", nam)
            # If short form in table with same value, continue, otherwise, add short form
            upval = get(names, nam[2:end], "") # see if "up..." is in the table
            shortval = get(names, nam[4:end], "") # see if "..." is in the table
            val == shortval && continue # short name is already in table with same value
            add_name(valtonam, val, shortval == "" ? nam[4:end] : nam[2:end])
            continue
        else
            for (pref, rep) in replace_prefix
                if startswith(pref, nam)
                    tst = rep * nam[sizeof(pref)+1:end]
                    if haskey(names, tst)
                        print("Conflict: $nam => $val with prefix replaced ")
                        println("$tst => $(collect(names[tst]))")
                    else
                        nam = tst
                    end
                    break
                end
            end
        end
        add_name(valtonam, val, nam)
        # Produce short forms for Greek and numbers
        siz = sizeof(nam)
        siz > 3 || continue
        replace_suffix(valtonam, val, nam, "gr", greek_letters) && continue
        replace_suffix(valtonam, val, nam, "gv", var_greek) && continue
        if nam[1] == 'i' && nam[2] == 't'
            replace_all(valtonam, val, nam[3:end], "ig", "iv", "it") && continue
        elseif nam[1] == 'b'
            if nam[2] == 'f'
                replace_all(valtonam, val, nam[3:end], "bg", "bv", "bf") && continue
            elseif nam[2] == 's' && siz > 6 && nam[3] == 'a' && nam[4] == 'n' && nam[5] == 's'
                replace_all(valtonam, val, nam[6:end], "bsg", "bsv", "bs") && continue
            elseif nam[2] == 'i'
                if nam[3] == 's' && siz > 7 && nam[4] == 'a' && nam[5] == 'n' && nam[6] == 's'
                    replace_all(valtonam, val, nam[7:end], "bisg", "bisv", "bis") && continue
                else
                    replace_all(valtonam, val, nam[3:end], "big", "biv", "bi") && continue
                end
            end
        end
    end
    # Split into two vectors
    syms = Vector{String}()
    vals = Vector{String}()
    for (val, names) in valtonam, nam in names
        push!(syms, nam)
        push!(vals, val)
    end
    syms, vals
end

function make_tables()
    sym1, ver1, inf1 = get_math_symbols(dpath, fname)
    sym2, ver2, inf2 = add_math_symbols(lpath, lname)

    latex_sym = [mansym..., sym1[1], sym2, sym1[2:end]...]
    et = (mantyp..., element_types[1], "tex", element_types[2:end]...)

    latex_set = Dict{String,String}()
    diff_set = Dict{String,Set{String}}()

    # Select the first name found, ignore duplicates
    for (ind, sym_set) in enumerate(latex_sym)
        countdup = 0
        countdiff = 0
        for (nam, val) in sym_set
            old = get(latex_set, nam, "")
            if old == ""
                push!(latex_set, nam => val)
            elseif val == old
                countdup += 1
            else
                countdiff += 1
                if haskey(diff_set, nam)
                    push!(diff_set[nam], val)
                else
                    push!(diff_set, nam => Set([old, val]))
                end
            end
        end
        println(countdup, " duplicates, ", countdiff, " overwritten out of ", length(sym_set),
                " found in ", et[ind])
    end
    # Now, replace or remove prefixes and suffixes
    symnam, symval = shorten_names(latex_set)

    println(length(symval), " distinct entities found")
    
    # We want to build a table of all the names, sort them, then create a StrTable out of them
    srtnam = sortperm(symnam)
    srtval = symval[srtnam] # Values, sorted the same as srtnam

    # BMP characters
    l16 = Tuple{UInt16, UInt16}[]
    # non-BMP characters (in range 0x10000 - 0x1ffff)
    l32 = Tuple{UInt16, UInt16}[]
    # two characters packed into UInt32, first character in high 16-bits
    l2c = Tuple{UInt32, UInt16}[]

    for i in eachindex(srtnam)
        chrs = srtval[i]
        len = length(chrs)
        len > 2 && error("Too long sequence of characters $chrs")
        ch1 = chrs[1]%UInt32
        if len == 2
            ch2 = chrs[end]%UInt32
            (ch1 > 0x0ffff || ch2 > 0x0ffff) &&
                error("Character $ch1 or $ch2 > 0xffff")
            push!(l2c, (ch1<<16 | ch2, i))
        elseif ch1 > 0x1ffff
            error("Character $ch1 too large")
        elseif ch1 > 0x0ffff
            push!(l32, (ch1-0x10000, i))
        else
            push!(l16, (ch1%UInt16, i))
        end
    end

    # We now have 3 vectors, for single BMP characters, for non-BMP characters, and for 2 BMP chars
    # each has the value and a index into the name table
    # We need to create a vector the same size as the name table, that gives the index
    # of into one of the three tables, in order to go from names to 1 or 2 output characters
    # We also need, for each of the 3 tables, a sorted vector that goes from the indices
    # in each table to the index into the name table (so that we can find multiple names for
    # each character)

    indvec = create_vector(UInt16, length(srtnam))
    vec16, ind16, base32 = sortsplit!(indvec, l16, 0)
    vec32, ind32, base2c = sortsplit!(indvec, l32, base32)
    vec2c, ind2c, basefn = sortsplit!(indvec, l2c, base2c)

    ((VER, string(now()), string(ver1, ",", ver2),
      base32%UInt32, base2c%UInt32, StrTable(symnam[srtnam]), indvec,
      vec16, ind16, vec32, ind32, vec2c, ind2c),
     (ver1, ver2), (inf1, inf2))
end

println("Creating tables")
tup = nothing
try
    global tup
    tup = make_tables()
catch ex
    println(sprint(showerror, ex, catch_backtrace()))
end
savfile = joinpath(datapath, "latex.dat")
println("Saving tables to ", savfile)
StrTables.save(savfile, tup[1])
println("Done")

