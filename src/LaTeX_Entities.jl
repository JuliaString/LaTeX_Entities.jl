"""
Public API (nothing is exported)
lookupname(str)
matches(str)
longestmatch(str)
completions(str)
"""
module LaTeX_Entities
using StrTables

include("latex_table.jl")

const _lt =
    LaTeX_Table(StrTables.load(joinpath(Pkg.dir("LaTeX_Entities"), "data", "latex.dat"))...)

function _get_str(ind)
    ind <= _lt.base32 && return string(Char(_lt.val16[ind]))
    ind <= _lt.base2c && return string(Char(_lt.val32[ind - _lt.base32] + 0x10000))
    val = _lt.val2c[ind - _lt.base2c]
    string(Char(val>>>16), Char(val&0xffff))
end
    
const _empty_str = ""
const _empty_str_vec = Vector{String}()

"""Given a LaTeX name, return the string it represents, or an empty string if not found"""
function lookupname(str::AbstractString)
    rng = searchsorted(_lt.nam, str)
    isempty(rng) ? _empty_str : _get_str(_lt.ind[rng.start])
end

function _get_strings{T}(val::T, tab::Vector{T}, ind::Vector{UInt16})
    rng = searchsorted(tab, val)
    isempty(rng) && return _empty_str_vec
    _lt.nam[ind[rng]]
end

"""Given a string, return all exact matches to the string as a vector"""
matches(str::AbstractString) = matches(convert(Vector{Char}, str))

function matches(vec::Vector{Char})
    if length(vec) == 1
        if vec[1] > '\uffff'
            _get_strings((vec[1]%UInt32-0x10000)%UInt16, _lt.val32, _lt.ind32)
        else
            _get_strings(vec[1]%UInt16, _lt.val16, _lt.ind16)
        end
    elseif length(vec) == 2 && (vec[1] <= '\uffff' && vec[2] <= '\uffff')
        _get_strings(vec[1]%UInt32<<16 | vec[2]%UInt32, _lt.val2c, _lt.ind2c)
    else
        _empty_str_vec
    end
end

"""Given a string, return all of the longest matches to the beginning of the string as a vector"""
longestmatches(str::AbstractString) = longestmatches(convert(Vector{Char}, str))

function longestmatches(vec::Vector{Char})
    isempty(vec) && return _empty_str_vec
    if length(vec) >= 2 && (vec[1] <= '\uffff' && vec[2] <= '\uffff')
        res = _get_strings(vec[1]%UInt32<<16 | vec[2]%UInt32, _lt.val2c, _lt.ind2c)
        isempty(res) || return res
        # Fall through and check only the first character
    end
    if vec[1] > '\uffff'
        _get_strings((vec[1]%UInt32-0x10000)%UInt16, _lt.val32, _lt.ind32)
    else
        _get_strings(vec[1]%UInt16, _lt.val16, _lt.ind16)
    end
end


"""Given a string, return all of the LaTeX names that start with that string, if any"""
completions(str::AbstractString) = completions(convert(String, str))
completions(str::String) = StrTables.matchfirst(_lt.nam, str)

end # module
