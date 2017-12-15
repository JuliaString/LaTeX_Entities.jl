# License is MIT: https://github.com/JuliaString/LaTeX_Entities/LICENSE.md

__precompile__()

"""
# Public API (nothing is exported)

* lookupname(str)
* matchchar(char)
* matches(str)
* longestmatches(str)
* completions(str)
"""
module LaTeX_Entities

using StrTables

VER = UInt32(1)

struct LaTeX_Table{T} <: AbstractEntityTable
    ver::UInt32
    tim::String
    inf::String
    base32::UInt32
    base2c::UInt32
    nam::StrTable{T}
    ind::Vector{UInt16}
    val16::Vector{UInt16}
    ind16::Vector{UInt16}
    val32::Vector{UInt16}
    ind32::Vector{UInt16}
    val2c::Vector{UInt32}
    ind2c::Vector{UInt16}
end

function __init__()
    const global _tab =
        LaTeX_Table(StrTables.load(joinpath(Pkg.dir("LaTeX_Entities"), "data", "latex.dat"))...)
    nothing
end

const _empty_str = ""
const _empty_str_vec = Vector{String}()

function _get_str(ind)
    ind <= _tab.base32 && return string(Char(_tab.val16[ind]))
    ind <= _tab.base2c && return string(Char(_tab.val32[ind - _tab.base32] + 0x10000))
    val = _tab.val2c[ind - _tab.base2c]
    string(Char(val>>>16), Char(val&0xffff))
end
    
function _get_strings(val::T, tab::Vector{T}, ind::Vector{UInt16}) where {T}
    rng = searchsorted(tab, val)
    isempty(rng) && return _empty_str_vec
    _tab.nam[ind[rng]]
end

function lookupname(str::AbstractString)
    rng = searchsorted(_tab.nam, str)
    isempty(rng) ? _empty_str : _get_str(_tab.ind[rng.start])
end

matchchar(ch::UInt32) =
    (ch <= 0x0ffff
     ? _get_strings(ch%UInt16, _tab.val16, _tab.ind16)
     : (ch <= 0x1ffff ? _get_strings(ch%UInt16, _tab.val32, _tab.ind32) : _empty_str_vec))
matchchar(ch::Char) = matchchar(UInt32(ch))

matches(str::AbstractString) = matches(convert(Vector{Char}, str))
function matches(vec::Vector{Char})
    if length(vec) == 1
        matchchar(vec[1])
    elseif length(vec) == 2 && (vec[1] <= '\uffff' && vec[2] <= '\uffff')
        _get_strings(vec[1]%UInt32<<16 | vec[2]%UInt32, _tab.val2c, _tab.ind2c)
    else
        _empty_str_vec
    end
end

longestmatches(str::AbstractString) = longestmatches(convert(Vector{Char}, str))
function longestmatches(vec::Vector{Char})
    isempty(vec) && return _empty_str_vec
    if length(vec) >= 2 && (vec[1] <= '\uffff' && vec[2] <= '\uffff')
        res = _get_strings(vec[1]%UInt32<<16 | vec[2]%UInt32, _tab.val2c, _tab.ind2c)
        isempty(res) || return res
        # Fall through and check only the first character
    end
    matchchar(vec[1])
end

completions(str::String) = StrTables.matchfirst(_tab.nam, str)
completions(str::AbstractString) = completions(convert(String, str))

end # module LaTeX_Entities
